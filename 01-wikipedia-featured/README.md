# wikipedia featured

Using the Wikipedia API to get information about featured events, including news, articles, and things that happened on a specific date.

## notes

The api can be found here: https://api.m.wikimedia.org/wiki/Feed_API/Reference/Featured_content

```
/feed/v1/wikipedia/{language}/featured/{YYYY}/{MM}/{DD} 
```

So specifically with curl:

```bash
curl https://api.wikimedia.org/feed/v1/wikipedia/en/featured/2025/06/23
```
