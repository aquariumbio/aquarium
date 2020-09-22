# API v2 documentation

This document describes the current API v2

---

## General

1. If the API returns valid data

    ```bash
    {
      "status": 200,
      "data": <response>
    }
    ```
    where &lt;response>
    - is **always** an <code>[ array_of_objects ]</code> if there can be 1-or-more objects
    - is **always** an <code>{ object }</code> if there is *always* only 1 object

1. If the API returns errors

    ```bash
    {
      "status": 400,
      "data": <errors>
    }
    ```
    where &lt;errors>
    - is **always** in the format <code>{ field_1: [ field_1_error_messages ], field_2: [ field_1_error_messages ], ... }</code>

## Implemented API Calls


1. Get Users
    ```bash
    GET /api/v2/users
    ```

2. Get User &ltuser_id>
    ```bash
    GET /api/v2/users/<user_id>
    ```

3. Get Jobs run by User &lt;user_id>
    ```bash
    GET /api/v2/users/<user_id>/jobs
    DATA: { status = [ one-or-more <job status> ] }
    ```

    <div>
      where
      <ul><li>
        Valid &lt;job status> values are 'pending', 'running', and 'done'
      </li><li>
         DATA can be passed as key-value pairs or as formdata in an AJAX request
      </li><li>
         If there are no (valid) status[] parameters, the API returns all jobs run by &lt;user_id>
      </li><li>
         If there are one-or-more (valid) status[] paremeters, the API returns those jobs that have any of the statuses (i.e., uses OR logic)
      </li></ul>
    </div>
    <br>

    <div>
      Example: To get jobs that are still running
      <ul><li>
        GET /api/v2/users/1/jobs?status[]=running
      </li></ul>
    </div>


4. Get Jobs assigned to User &lt;user_id>
    ```bash
    GET /api/v2/users/<user_id>/assigned_jobs
    DATA: { status = [ one-or-more <job status> ] }
    ```

    <div>
      where
      <ul><li>
        Valid &lt;job status> values are 'pending', 'running', and 'done'
      </li><li>
         DATA can be passed as key-value pairs or as formdata in an AJAX request
      </li><li>
         If there are no (valid) status[] parameters, the API returns all jobs run by &lt;user_id>
      </li><li>
         If there are one-or-more (valid) status[] paremeters, the API returns those jobs that have any of the statuses (i.e., uses OR logic)
      </li></ul>
    </div>
    <br>

    <div>
      Example: To get assigned jobs that are not done
      <ul><li>
        GET /api/v2/users/1/assigned_jobs?status[]=pending&status[]=running
      </li></ul>
    </div>

5. Get Job &lt;job_id>
    ```bash
    GET /api/v2/jobs/<job_id>
    ```

6. Get current assignment for Job &lt;job_id>
    ```bash
    GET /api/v2/jobs/<job_id>/assignment
    ```

7. Assign Job &lt;job_id> to User &lt;to_id>
    ```bash
    POST /api/v2/jobs/<job_id>/assign?to=<to_id> (1)
    ```

8. Unassign Job &lt;job_id>
    ```bash
    POST /api/v2/jobs/<job_id>/unassign (1)
    ```

9. Get Groups
    ```bash
    GET /api/v2/groups
    ```

10. Get Group &lt;group_id>
    ```bash
    GET /api/v2/groups/<group_id>
    ```

11. Get Users in Group &lt;group_id>
    ```bash
    GET /api/v2/groups/<group_id>/users
    ```

12. Get Users in Role &lt;role_id = 10>
    ```bash
    GET /api/v2/roles/10/users  (2)
    ```

**Notes**
- (1) the by_id will be the current_user.
- (2) hardcoded URL in the routing table that goes to /api/v2/groups/55/users.  When we introduce roles this will be implemented in api/v2/roles_controller.
