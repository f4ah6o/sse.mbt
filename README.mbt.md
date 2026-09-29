# sse.mbt

Server-Sent Events (SSE) support for MoonBit/JS.

This library provides a type-safe interface to the browser's [EventSource API](https://developer.mozilla.org/en-US/docs/Web/API/EventSource) for receiving server-sent events in MoonBit applications targeting JavaScript.

## Features

- Type-safe SSE client implementation
- Fluent API for event handler registration
- Automatic reconnection with configurable retry logic
- Connection state management
- Event message parsing with optional ID tracking
- Property-based testing coverage
- Browser client built on the native `EventSource` API
- Native-only server support uses `moonbitlang/async/socket`

## Installation

```bash
moon add f4ah6o/sse@0.3.1
```

## Usage

```mbt nocheck
///|
import {
  "f4ah6o/sse/src/sse",
}

///|
fn main {
  let conn = @sse.connect("http://localhost:8080/events")

  conn
  |> @sse.on_message(fn(msg) { println("Received: \{msg.data}") })
  |> @sse.on_error(fn(err) { println("Error: \{err}") })
  |> @sse.on_open(fn(_state) { println("Connection opened") })

  // Close when done
  @sse.close(conn)
}
```

### Named Events

```mbt nocheck
import {
  "f4ah6o/sse/src/sse" @sse,
}

let conn = @sse.connect("http://localhost:8080/events")

conn
  |> @sse.on("notification", fn(msg) {
    println("Notification: \{msg.data}")
  })
  |> @sse.on("update", fn(msg) {
    println("Update: \{msg.data}")
  })
```

### Auto-Reconnection

```mbt nocheck
///|
import {
  "f4ah6o/sse/src/sse",
}

///|
let conn = @sse.connect("http://localhost:8080/events")
  |> @sse.setup_auto_reconnect
  |> @sse.on_message(fn(msg) { println("Received: \{msg.data}") })

// Will automatically reconnect on connection loss
// up to max_retries times with reconnect_interval delay
```

### Custom Configuration

```mbt nocheck
import {
  "f4ah6o/sse" @root,
  "f4ah6o/sse/src/sse" @sse,
}

let config = {
  ...@root.default_connection_config("http://localhost:8080/events")
  with_credentials: true
  reconnect_interval: 5000
  max_retries: 5
}

let conn = @sse.connect_with_config(config)
  |> @sse.on_message(fn(msg) {
    println("Event: \{msg.event_name}, Data: \{msg.data}")
  })
```

## Building & Testing

```bash
# Check formatting and all supported targets
moon fmt --check
moon check --target all

# Check each target-specific subpackage
moon check src/sse --target js
moon check src/server --target native

# Run tests for all supported targets
moon test --target all

# Update snapshots after behavioral changes
moon test --target all --update
```

## License

Apache-2.0
