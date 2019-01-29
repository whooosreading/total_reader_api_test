# Total Reader API test

## Environment

Clone this repo:
```
git clone git@github.com:whooosreading/total_reader_api_test.git
```

This was implemented with ruby version `2.4.1p111` and will require at LEAST ruby 2.0 but may need a higher version. Ruby 2.4.1 or higher would be safest.

## Description

Sample integration to help with debugging Total Reader API issues.

Simlulates multiple users getting identified for the first time, then trying to fetch categories.

Flow:

1. Try to fetch user data with `GET /categories/:refId`
2. If the fetch fails (if should), `POST /users` to make the record
3. Wait 500ms
4. Fetch categories with `/categories/:refId`, which should tell us we need to take a diagnostic

To run against development API:
```
API_KEY=aaaa-1111-bbbb SECRET_KEY=1234abcd ruby test.rb
```

To run against production API:
```
ENV=production API_KEY=zzzz-9999-yyyy SECRET_KEY=9876wxyz ruby test.rb
```
