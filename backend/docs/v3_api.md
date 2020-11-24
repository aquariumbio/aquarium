# API v3 Documentation

This document describes the current API v3

---

## API Status Codes

### Normal Use Case

1. If the API is valid and returns success

    ```bash
    status: :ok (200) / :created (201)
    {
      key_1: value_1,
      key_2: value_2,
      ...
    }
    ```

    where each value is always

    ```bash
    - an < element >
    - an { object } if there is always only 1 object for that key
    - an [ array_of_objects ] if there can be 1-or-more objects for that key
    ```

2. If the API is valid and returns errors on their input form

    ```bash
    status: :ok (200)
    {
      errors
    }
    ```

    where { errors } is always in the format

    ```bash
    {
      field_1: [ field_1_error_messages ],
      field_2: [ field_1_error_messages ],
      ...
    }
    ```

### Token & Permission Errors

1. If the API token does not exist

   ```bash
   status: :unauthorized (401),
   {
     error: "Invalid"
   }
   ```

2. If the API token is valid but the session has timed out

    ```bash
    status: :unauthorized (401),
    {
      error: "Session timeout."
    }
    ```

3. If the API token is valid but the user does not have permission to see the page

    ```bash
    status: :forbidden (403),
    {
      error: "<permission> permissions required." / "Forbidden."
    }
    ```

## Implemented API Calls (TODO)

### TOKENS

  POST api/v3/token/create

  POST api/v3/token/delete

  GET  api/v3/token/get_user

### PERMISSIONS

  get  api/v3/permissions

### USER PERMISSIONS

  GET  api/v3/users/permissions

  POST api/v3/users/permissions/update

### SAMPLE TYPES

  GET  api/v3/sample_types

  POST api/v3/sample_types/create

  GET  api/v3/sample_types/:id

  POST api/v3/sample_types/:id/update

  POST api/v3/sample_types/:id/delete
