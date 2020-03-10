require 'json'
require 'net/http'

maxlng = -180
maxlat = -90
minlng = 180
minlat = 90

geojson = {
  'type' => 'FeatureCollection',
  'features' => []
}

offset = 0
unique = []

loop do

  res = JSON.parse(Net::HTTP.get(URI('https://api.foursquare.com/v2/users/self/checkins?oauth_token=' + ARGV[0] + '&v=20200303&limit=250&offset=' + offset.to_s)))

  if (res['meta']['code'] != 200)
    exit
  end

  res['response']['checkins']['items'].each do |child|
    next if unique.include? child['venue']['id']
    unique << child['venue']['id']
    geojson['features'] << {
      'type' => 'Feature',
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          child['venue']['location']['lng'],
          child['venue']['location']['lat']
        ]
      },
      'properties' => {
        'id' => child['venue']['id'],
        'name' => child['venue']['name'],
        'address' => child['venue']['location']['formattedAddress']
      }
    }
    if child['venue']['location']['lng'] > maxlng
      maxlng = child['venue']['location']['lng'];
    end
    if child['venue']['location']['lat'] > maxlat
      maxlat = child['venue']['location']['lat'];
    end
    if child['venue']['location']['lng'] < minlng
      minlng = child['venue']['location']['lng'];
    end
    if child['venue']['location']['lat'] < minlat
      minlat = child['venue']['location']['lat'];
    end
  end

  offset += 250

  break if res['response']['checkins']['items'].length() == 0

end

bounds = [
  [minlng - (maxlng - minlng) * 0.05, minlat - (maxlat - minlat) * 0.05],
  [maxlng + (maxlng - minlng) * 0.05, maxlat + (maxlat - minlat) * 0.05]
]

file = File.open("places.geojson", "w")
file.puts(JSON[geojson])
file.close

file = File.open("bounds.js", "w")
file.puts('var bounds = ' + JSON[bounds] + ';')
file.close
