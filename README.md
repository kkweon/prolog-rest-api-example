# Prolog Todo API

A RESTful Todo API implementation in Prolog.

## Code Structure

### Main Application (`main.pl`)

The entry point of the application that handles HTTP routing and request processing.

Key components:

- HTTP request handlers for CRUD operations
- Route definitions using `http_handler`
- Request validation and error handling
- JSON response formatting

## Running the Server

To start the server:

1. Make sure you have SWI-Prolog installed
2. From the project root directory, start the server on port 8080:
   ```prolog
   swipl main.pl -g "main(8080)."
   ```

## Testing the API

The API endpoints can be tested using the provided HTTP request file in `e2e/cuj.http`. If using VS Code with the REST Client extension, you can execute the requests directly from the editor.

Available endpoints:

- `GET /api/todos` - List all todos
- `POST /api/todos` - Create a new todo
- `GET /api/todos/:id` - Get a specific todo
- `PUT /api/todos/:id` - Update a todo
- `DELETE /api/todos/:id` - Delete a todo

Example using HTTPie:

```bash
# Get all todos
http :8080/api/todos

# Create a new todo
http POST :8080/api/todos title="Buy groceries"

# Get a specific todo (replace 123 with the actual ID)
http :8080/api/todos/123

# Update a todo (replace 123 with the actual ID)
http PUT :8080/api/todos/123 title="Buy milk and bread"

# Delete a todo (replace 123 with the actual ID)
http DELETE :8080/api/todos/123
```

