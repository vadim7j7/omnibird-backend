# Sandbox Google

### 1.  Get Google OAuth URL to send an email.
To generate the OAuth URL for Google, run the following command:
```shell
rails google_sandbox:oauth_url
```

### 2. Exchange the code for credentials and save them in the database.
```CODE``` is the code that Google generates and returns after a successful OAuth flow.
```STATE``` is the state that Google sends back from the OAuth URL.

To exchange the code for a token and save the credentials:
```shell
CODE=your_google_code STATE=your_google_state rails google_sandbox:code_to_token
```

### 3. Send an email from the connected Google account.

Send just an HTML email     
To send a basic HTML email:
#### Send Just HTML email
```shell
TO=recipient@example.com rails google_sandbox:send_email
```

Send an HTML email with an attached file
#### To send an email with an attachment:
```shell
FILE_URL=/path/to/file.txt TO=recipient@example.com rails google_sandbox:send_email
```

### 4. Send a reply to an existing email
```IN_REPLY_TO``` is the ID of the previous email.

To send a reply:
####
```shell
IN_REPLY_TO="previous_email_id" TO=recipient@example.com rails google_sandbox:send_email
```

# Sandbox Microsoft

### 1.  Get Microsoft OAuth URL to send an email.
To generate the OAuth URL for Microsoft, run the following command:
```shell
rails microsoft_sandbox:oauth_url
```

### 2. Exchange the code for credentials and save them in the database.
```CODE``` is the code that Microsoft generates and returns after a successful OAuth flow.
```STATE``` is the state that Microsoft sends back from the OAuth URL.

To exchange the code for a token and save the credentials:
```shell
CODE=your_microsoft_code STATE=your_state rails microsoft_sandbox:code_to_token
```

### 3. Send an email from the connected Microsoft account.

Send just an HTML email     
To send a basic HTML email:
#### Send Just HTML email
```shell
TO=recipient@example.com rails microsoft_sandbox:send_email
```

Send an HTML email with an attached file
#### To send an email with an attachment:
```shell
FILE_URL=/path/to/file.txt TO=recipient@example.com rails microsoft_sandbox:send_email
```

### 4. Send a reply to an existing email
```IN_REPLY_TO``` is the ID of the previous email.

To send a reply:
####
```shell
IN_REPLY_TO="previous_email_id" TO=recipient@example.com rails microsoft_sandbox:send_email
```
