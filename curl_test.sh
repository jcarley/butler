#!/usr/bin/env bash

# curl 'http://localhost:9292/api/submission/v1/submission_batches/31/contributions?minimal_logging=true'

# -H 'X-CSRF-TOKEN: 8gFIs4ReiLE16NYZIq6bGE2SNLj0BAxYbeEAquC0OSM='
# -H 'Accept: application/json, text/plain, */*'
# -H 'Cookie: m=3247:t|34e2:|18c3:t|47ba:t|4a01:t|2a03:t|77cb:t|ca3:t|41b8:f|1b3b:5000;

# auth=CJ8gUsdMqwB4lSZW0xXa1qKrpEP6JCx1Utklxt4NqyKyB9sjl650lf0zgVSzDmM%2FKDqacrvJurD1Dca5forcebZxl3l56YUXZX7US6eabF28CWPdm2PxY9Wpl8JJMqNvNioW2GPEwlPw7UZ%2F%2BcyF27mJmRUHCVd%2FudzG9ht3wDM%3D%7C77u%2FN01BTU9rOUdHR3BmSXZybUdWMHYKMTUyMAo3NDkyNzQKVWRyNEJnPT0KV2VINEJnPT0KMAoKMTI3LjAuMC4xCjAKMTUyMApZMlVIQnc9PQoxNTIwCjAKCg%3D%3D%7C3;

# user_id=6;
# username=myeung;
# integration_id=749274;
# _submission_session=SWE1c3N5WWRuYkJEam1ISWhGNGhTRFVPdVNvTm1qMmliTXFSVlBHT2dQVUlkVW9yNmI1RzNjeVBRUGtxSjZwcEdaQnQwSEN5b2tXdmxRNmJtRmhNdXl6UnZScGpMemFEUk9Tc1dyY3BZbmRRNXFHWHh1RDJQdCtHaVJkOUZWYXpscDlsWC9BSUNOL0VvdUQyb015eFBySjRnK0FVL2puVDNzaUZkUGk1c2sxTDFDeHNtcElhSnQ5c2QzU3djMWRWLS0zemxRNi9TaU1RS3ZhbXQxMDlUWU9nPT0%3D--93dbf392d737c6facd2b4ccc1b1c0287145d5e6a'

# Authorization: Token token="abc"


# curl localhost:9292/api/submission/v2/contributions
# curl localhost:9292/api/review/v2/reviews

# Valid test curl request
curl -H 'Accept: application/json' -H 'Authorization: Token token="CJ8gUsdMqwB4lSZW0xXa1qKrpEP6JCx1Utklxt4NqyKyB9sjl650lf0zgVSzDmM%2FKDqacrvJurD1Dca5forcebZxl3l56YUXZX7US6eabF28CWPdm2PxY9Wpl8JJMqNvNioW2GPEwlPw7UZ%2F%2BcyF27mJmRUHCVd%2FudzG9ht3wDM%3D%7C77u%2FN01BTU9rOUdHR3BmSXZybUdWMHYKMTUyMAo3NDkyNzQKVWRyNEJnPT0KV2VINEJnPT0KMAoKMTI3LjAuMC4xCjAKMTUyMApZMlVIQnc9PQoxNTIwCjAKCg%3D%3D%7C3"' localhost:9292/api/submission/v1/contributions
