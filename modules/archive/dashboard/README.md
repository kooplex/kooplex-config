# A recipe for deploying a dashboard servers and kernel gateway servers

## Architecture overview

Services are run behind a proxy `nginx` on our case.

```
Actor [nginx/dashboard interface] dashboard [kernel gateway API] kernel gateway
```

As many kernel gateways are running as many images are published.
A kernel gateway may serve more than one dashboard servers.
A dashboard server may contain and serve more than one notebooks.

## Prerequisites

* Access to the internet to retrieve latest version of the `dashboard_server` source from the [git repository](https://github.com/jupyter-incubator/dashboards_server)

### Known bugs

`dashboard_server` v 0.9.x-dev implements `BASE_URL` prefixes, which we need for the proxying. This feature is not yet fully implemented:

* the `/login` URL does not provide it, so simple authentication is not possible yet.
* static CSS and possibly few javascipt components do not prepend `BASE_URL` they need a patch

