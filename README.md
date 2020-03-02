# post-data

An alternative to mod_harbour's `AP_PostPairs()` function to get the `POST`
parameters from a form as a harbour hash. The (planned) differences from
`AP_PostPairs()` are:

- A correct implementation of the `application/x-www-form-urlencoded` decoder.
- Additional support for the `multipart/form-data` and `application/json`
  formats for `POST` data. This will include the ability to handle file uploads.
- Support for obtaining metadata for uploaded files, such as their filename and
  MIME type.

This project is free and open-source software available under the MIT license.
Please feel free to contribute to the project.
