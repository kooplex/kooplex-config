
## INIT for openid
${MODULE_NAME} admin auth add-oauth --name kooplex-test --provider openidConnect --auto-discover-url https://kooplex-test.elte.hu/hydra/.well-known/openid-configuration --key kooplex-test-${MODULE_NAME} --secret vmi

## Setup app.ini in gitea for openid
Don't forget to restart it

# GITEA html templates from https://github.com/go-gitea/gitea.git

