from gevent import monkey

monkey.patch_all()
import os
import logging
from jose import jwt
import requests
from flask import Flask, request, abort
from azure.identity import (
    DefaultAzureCredential,
    EnvironmentCredential,
    ManagedIdentityCredential,
)
from azure.keyvault.secrets import SecretClient
from dotenv import load_dotenv

load_dotenv()
APP_ENV = os.getenv("ENV", "LOCAL")
TENANT_ID = os.getenv("AZURE_TENANT_ID", "")
CLIENT_ID = os.getenv("AZURE_CLIENT_ID", "")

logging.basicConfig(level=logging.INFO)
logging.getLogger("azure.core.pipeline.policies.http_logging_policy").setLevel(
    logging.WARNING
)

key_vault_name = "prod-demoflask"
KVUri = f"https://{key_vault_name}.vault.azure.net"
app = Flask(__name__)

credential = EnvironmentCredential()
if APP_ENV == "CLOUD":
    CLIENT_ID = os.getenv("AZ_CA_CLIENT_ID")
    credential = ManagedIdentityCredential(client_id=os.getenv("AZ_CA_CLIENT_ID"))


@app.route("/whoami")
def whoami():
    user_email = request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME")
    id_token = request.headers.get(
        "X-MS-TOKEN-AAD-ID-TOKEN"
    )  # reveals email and username when decoded
    claims = verify_id_token(id_token)
    return {
        "user": user_email,
        "id_token": id_token,
        "claims": claims,
    }


@app.route("/secret", methods=["GET"])
def secret():
    client = SecretClient(vault_url=KVUri, credential=credential)
    secret_name = "testjuttu"
    retrieved_secret = client.get_secret(secret_name)
    return f"Secret '{secret_name}': {retrieved_secret.value}"


@app.route("/hello", methods=["GET", "POST"])
def hello():
    test_var = os.getenv("TESTSECRET")
    return f"Hello, {test_var} world! V0.3"


@app.route("/", methods=["GET"])
def home():
    return "works"


def verify_id_token(id_token):
    """
    Decode and verify.
    """
    # TODO: check issuer matches my organization issuer before accepting the claims!

    # return jwt.get_unverified_claims(id_token) # this will just decode without verification.
    config_url = f"https://login.microsoftonline.com/{TENANT_ID}/v2.0/.well-known/openid-configuration"
    config = requests.get(config_url).json()
    jwks_uri = config["jwks_uri"]
    jwks = requests.get(jwks_uri).json()
    try:
        claims = jwt.decode(
            id_token,
            jwks,
            algorithms=["RS256"],
            audience=os.getenv("AAD_CLIENT_ID"),
            issuer=f"https://login.microsoftonline.com/{TENANT_ID}/v2.0",
        )
        return claims
    except Exception as e:
        return f"decode failed: {e}"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
