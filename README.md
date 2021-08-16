# Bamboo.GmailAdapter

[![Hex.pm](https://img.shields.io/hexpm/v/bamboo_gmail)](https://hex.pm/packages/bamboo_gmail)

Gmail adapter for [Bamboo](https://github.com/thoughtbot/bamboo)

## Quick Links
* [Preconditions](#preconditions)
* [Installation](#installation)
* [Configuration](#configuration)
* [Documentation](#documentation)
* [Contribute](#contribute)

---

## Motivation

*Why not just use SMTP?*

Starting in 2020, [Google is deprecating the use of its Gmail API with SMTP usage](https://gsuiteupdates.googleblog.com/2019/12/less-secure-apps-oauth-google-username-password-incorrect.html).
This adapter allows GSuite account holders to use Bamboo in light of this deprecation by using OAuth2 for authentication.

---

## Preconditions

There are a few preconditions that must be met before this adapter can be used to send email:
1. Admin access to a Google Workspace account (NOTE: your personal Gmail accounts WILL NOT WORK)
2. Enable Gmail API GCP Console
2. Implement [server-side authorization](https://developers.google.com/gmail/api/auth/web-server) using Service Account credentials
  - Don't give any GCP roles for the service account.
  - Add your Google Workspace email as a user, as servicer account Owner role.
  - If you have other Domain aliases, add those alias users in https://mail.google.com/mail/u/2/#settings/accounts, in "Send mail as"
3. Grant the service account domain-wide authority
  - first do here: https://console.cloud.google.com/iam-admin/serviceaccounts, by clicking the service account, and going to Domain Wide Delegation
  - Service account will create a related OAuth2.0 client id. 
4. Authorize API client with required scopes here: https://admin.google.com/u/2/ac/owl/domainwidedelegation
  - The scope that you need to add is: `https://www.googleapis.com/auth/gmail.send`

---

## Installation

The package can be installed by adding `bamboo_gmail` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bamboo_gmail, "~> 0.2.0"}
  ]
end
```

Some application settings must be configured. See the [example section](#example-config) below.

---

## Configuration

  | Setting | Description | Required? |
  | ---------- | ---------- | ---------- |
  | `adapter` | Bamboo adapter in use (`Bamboo.GmailAdapter`). | Yes |
  | `sub` | Email address the service account is impersonating (address the email is sent from).  If impersonation is not needed, then `nil` (it is likely needed). | Yes |
  |`sandbox` | Development mode that does not send email.  Details of the API call are instead output to the elixir console. | No |
  | `json` | Google auth crendentials must be provided in JSON format to the `:goth` app.  These are generated in the [Google Developers Console](https://console.developers.google.com/). | Yes |


---

#### Note: 

*Secrets such as the service account sub, and the auth credentials should not
be commited to version control.*

Instead, pass in via environment variables using a tuple: 
```elixir
{:system, "SUB_ADDRESS"}
```

Or read in from a file: 
```elixir
"creds.json" |> File.read!
```

---

## Example Config

```elixir
config :app_name, GmailAdapterTestWeb.Mailer,
  adapter: Bamboo.GmailAdapter,
  sub: {:system, "SUB_ADDRESS"},
  sandbox: false

# Google auth credentials must be provided to the `goth` app
config :goth, json: {:system, "GCP_CREDENTIALS"}
```

---

## Documentation

Docs can be found at [https://hexdocs.pm/bamboo_gmail](https://hexdocs.pm/bamboo_gmail).

---

## Contribute

Contribution Guidelines can be found [here](https://github.com/parkerduckworth/bamboo_gmail/blob/master/CONTRIBUTING.md).
Please feel free to use, share, and extend this project. PR's welcome.
