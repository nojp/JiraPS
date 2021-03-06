---
locale: en-US
layout: documentation
online version: https://atlassianps.org/docs/JiraPS/about/authentication.html
Module Name: JiraPS
permalink: /docs/JiraPS/about/authentication.html
---
# Authentication

## about_JiraPS_Authentication

# SHORT DESCRIPTION

In order to authenticate with the Jira server, the user can provide the
credentials with each command or create a session.

# LONG DESCRIPTION

At present, there are two main methods of authenticating to Jira:

* HTTP basic authentication
* session-based authentication,
which uses HTTP basic authentication once and preserves a session cookie.

> Be sure to set JIRA up to use HTTPS with a valid SSL certificate if you are
> concerned about security!

## HTTP Basic

Each JiraPS function that queries a Jira instance provides
a `-Credential` parameter.
Simply pass your Jira credentials to this parameter.

```powershell
$cred = Get-Credential 'powershell'
Get-JiraIssue TEST-01 -Credential $cred
```

> HTTP basic authentication is not a secure form of authentication.
> It uses a Base64-encoded String of the format "username:password"
> and passes this string in clear text to Jira. Because decrypting this
> string and obtaining the username and password is trivial,
> the use of HTTPS is critical in any system that needs to remain secure.

## API Token

API tokens (also called Private Access Token (PAT)) are tokens generated
by the user. This token is necessary when the user has a two-step verification
activated for his account.

An API token can be used for authenticating JiraPS with the server
in the same way as described in [HTTP Basic](#http-basic).
The only difference is, that instead of providing the password for the account,
the API token must be used.

> As of December 1st 2018, Atlassian requires API authentication
> with **Cloud Servers** to **always** use API Tokens.
> More information in the [Deprecation notice](https://developer.atlassian.com/cloud/jira/platform/deprecation-notice-basic-auth-and-cookie-based-auth/).

_More information on the API tokens and how to create one can be found at:_
_<https://confluence.atlassian.com/cloud/api-tokens-938839638.html>_

## Sessions

Jira sessions still require [HTTP Basic](#http-basic) or [API Token](#api-token)
Authentication once to create the connection.
But in this case a persistent session is saved as a `WebRequestSession`.
This is Powershell's way of reusing the data provided with the first call.

> Previously Jira allowed for the authentication to use a session token.
> This token did not contain the username and password.
> Unfortunately, this API can no longer be used in combination with this module.

To create a Jira session, you can use the New-JiraSession function:

```powershell
$cred = Get-Credential 'powershell'
New-JiraSession -Credential $cred
```

Once you've created this session, you're done!
You don't need to specify it when running other commands - JiraPS will
manage this session internally.

The session is stored in the module's runtime.
This means that it will not be available in a new Powershell session
or if the module is reloaded.

## What About OAuth

Jira does support use of OAuth, but JiraPS does not - yet.
This is a to-do item.

# SEE ALSO

* [Wikipedia's "Basic Access Authentication"](https://en.wikipedia.org/wiki/Basic_access_authentication)
* [Implement OAuth for JiraPS](https://github.com/AtlassianPS/JiraPS/issues/101)
