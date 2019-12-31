# Bamboo.GmailAdapter

Gmail adapter for [Bamboo](https://github.com/thoughtbot/bamboo)

*Why not just use SMTP?*

Starting in 2020, [Google is deprecating the use of its Gmail API with SMTP usage](https://gsuiteupdates.googleblog.com/2019/12/less-secure-apps-oauth-google-username-password-incorrect.html).
This adapter allows GSuite account holders to use Bamboo in light of this deprecation by using OAuth2 for authentication.

---

## Preconditions

There are a few preconditions that must be met before this adapter can be used to send email:
1. Admin access to a GSuite account
2. Implement [server-side authorization](https://developers.google.com/gmail/api/auth/web-server)
3. Grant the service account domain-wide authority
4. Authorize API client with required scopes

---

## Installation

The package can be installed by adding `bamboo_gmail` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bamboo_gmail, "~> 0.1.0"}
  ]
end
```

Some application settings must be configured. See the [example section](#example-config) below.

---

## Configuration

#### Required GmailAdapter settings:

`adapter`:
  - Bamboo adapter

`sub`:
  - Email address the service account is impersonating (address the email is sent from).
  - If impersonation is not needed, then `nil` (it is likely needed).


#### Required Dependency settings:

`json`: 
  - Google auth crendentials must be povided in JSON format.
  - These are generated in the [Google Developers Console](https://console.developers.google.com/)


#### Optional settings:

`sandbox`: 
  - Development mode that does not send email. 
  - details of the API call are instead output to the elixir console.

---

#### Note: 

*Secrets such as the service account sub, and the auth credentials should not
be commited to version control.*

- Instead, pass in via environment variables using a tuple: `{:system, "SUB_ADDRESS"}`,
- or read in from a file: `"creds.json" |> File.read!`

---

#### Example Config

```elixir
config :app_name, GmailAdapterTestWeb.Mailer,
  adapter: Bamboo.GmailAdapter,
  sub: {:system, "SUB_ADDRESS"},
  sandbox: false

# Google auth credentials must be provided to the `goth` app
config :goth, json: {:system, "GCP_CREDENTIALS"}
```
---

## Google Authorization/Authentication Help

The Google-related preconditions described above may be a little tricky.
If you find yourself stuck, please refer to the [wiki]() for help.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bamboo_gmail](https://hexdocs.pm/bamboo_gmail).

---

## Contribute

Contribution Guidelines can be found [here](https://github.com/parkerduckworth/bamboo_gmail/blob/master/CONTRIBUTING.md).
Please feel free to use, share, and extend this project. PR's welcome.
