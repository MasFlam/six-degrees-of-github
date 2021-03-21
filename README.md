# Six degrees of GitHub
What is your follower distance to someone famous? Check it with this [Julia](https://julialang.org) script.

### Usage
```
julia 6deg.jl <your oauth api token> <source user login> <target user login>
```

### Creating an API token
See the [guide](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) in the GitHub documentation.

### Rate limits
The GitHub REST API has rate limits. They are 5000 requests per hour per user for normal users. There's a high chance you'll run out of available requests. :(
