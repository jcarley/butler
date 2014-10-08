API Goals
---------
Customer Focus
  * Documentation
    - Examples
    - Sandbox
  * Intuitive
  * Digestable responses
  * Meaningful errors
  * Versioning
  * Token authorization

IT Focus
  * Maintainable
  * Organized
  * Monitoring
  * Versioning/Backwards compatibility
  * Deployable
  * Secure
  * Trusted
  * Productive
  * Migration strategy
  * Scale


How Grape fulfills those goals
------------------------------
* Can mount with just Rack, or along side Rack supported application (Rails, Sinatra)
  - Can mount multiple api implementations inside another one.  They don't have
    to be different versions, but may be components of the same API.
* Built in versioning (path, header, accept version header, param)
  - Can take advantage of the mounting multiple modules to support multiple versions of the app
* Takes strong parameters to the next level (requires, optional parameters.  adds validation and coercion)
  - https://github.com/intridea/grape#parameter-validation-and-coercion
  - https://github.com/intridea/grape#built-in-validators
* Use existing Active Model Serializers
* Helpers (an implicit inclusion of a module)
* Authentication
  - via Helpers
  - via custom Grape Middleware
* Pagination
  - grape-kaminari gem
  - grape-pagination
* Testing via Rails request specs.  Can still support the directory structure
  symmetry between project and specs
* CORS support
* Cookies
* Configurable logger
  - Plugin a Splunk Logger
* Built in documentation syntx (desc)
  - Grape-Swagger integration.  Gives documentation, and a test harness web UI.
    Deployed with the application.
* By pass rails with middleware



