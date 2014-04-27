SV ELLIPSIS
===========

Tools for running SV Ellipsis


* A worker that continuously reads BOAT data, decodes it and stores
* A Sinatra webapp as a visual interface for BOAT data


API
---

Boat data is available as a JSON api available by making a GET request to
[/data.json](http://live.ellipsis.voyage/data.json).

By default the endpoint shall return all data points available ordered to
display the most recent data points first, the data can be filtered and reduced
by using the following options:

### Resolution

**Not Yet Implemented**

The `resolution` parameter is a value in minutes that limits the data set to
only include one result line within this time period. This can be used if you
do not need high-fidelity data such as if you are plotting locations on a zoomed
out map.

Return a result set containing one item per hour:
    [/data.json?resolution=60](http://live.ellipsis.voyage/data.json?resolution=60)

Return a result set containing one item every 15 minutes:
    [/data.json?resolution=60](http://live.ellipsis.voyage/data.json?resolution=15)


### Start / End Times

The `start` and `end` parameters are ISO8601 formated datetimes that specify
the start and end times for the data set.

Return results since April 19th 2014:
    [/data.json?start=2014-04-19T00:00:00](http://live.ellipsis.voyage/data.json?start=2014-04-19T00:00:00)

Return results before June 1st 2014:
    [/data.json?start=2014-06-01T00:00:00](http://live.ellipsis.voyage/data.json?start=2014-06-01T00:00:00)

Return results from 1st to 31st of July 2014:
    [/data.json?start=2014-07-01T00:00:00&end=2014-07-31T23:59:59](http://live.ellipsis.voyage/data.json?start=2014-07-01T00:00:00&end=2014-07-31T23:59:59)


### Field Filters

The `filter` parameter is a comma separated list of fields to be returned. This
can be used if you only care about a subset of the fields such as only geodata.

Return only created at, latitude and longitude fields:
    [/data.json?fields=created_at,lat,long](http://live.ellipsis.voyage/data.json?fields=created_at,lat,long).


### Limit and Paging

The `limit` parameter is used to limit the amount of results returned.

The `page` parameter is used in conjunction with `limit' to offset the start
point of the query:

Return the last 20 results:
    [/data.json?limit=20](http://live.ellipsis.voyage/data.json?limit=20).

Return results 21-40:
    [/data.json?limit=20&page=2](http://live.ellipsis.voyage/data.json?limit=20&page=2).
