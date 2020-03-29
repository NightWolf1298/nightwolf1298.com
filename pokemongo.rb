require 'json'
require 'csv'

source = 'node_modules/pokemon-icons/_icons/SVG'

oldJson = nil
if (File.exist?('_data/pokedex.json'))
  oldJson = JSON.parse(File.read('_data/pokedex.json'))
end

json = {
  'normal' => {
    'kanto' => {},
    'johto' => {},
    'hoenn' => {},
    'sinnoh' => {},
    'unova' => {},
    'kalos' => {},
    'alola' => {},
    'unknown' => {}
  },
  'shiny' => {
    'kanto' => {},
    'johto' => {},
    'hoenn' => {},
    'sinnoh' => {},
    'unova' => {},
    'kalos' => {},
    'alola' => {},
    'unknown' => {}
  }
}

simpleData = nil
if (File.exist?('_data/simple-pokedex.csv'))
  simpleData = {}
 CSV.foreach('_data/simple-pokedex.csv', headers: true) do |row|
    simpleData[row['IconFile']] = { 'caught' => row['Caught'], 'caught_m' => row['CaughtM'],'caught_f' => row['CaughtF'] }
  end
end

totalCaught = 0
totalPokedex = 0

Dir.foreach(source) do |entry|
  if (entry[0] != '.')
    filename = entry
    name = filename + ''
    number = name[0..2].to_i
    if (number <= 151)
      region = 'kanto'
    elsif (number <= 251)
      region = 'johto'
    elsif (number <= 386)
      region = 'hoenn'
    elsif (number <= 493)
      region = 'sinnoh'
    elsif (number <= 649)
      region = 'unova'
    elsif (number <= 721)
      region = 'kalos'
    elsif (number <= 807)
      region = 'alola'
    else
      region = 'unknown'
    end

    m = /\d{3}-(?<name>[^-\.]+)(-(?<gender>[fm]))?(-(?<form>[^-\.]+))??(-(?<shiny>shiny))?\.svg/.match(name)
    if (m.nil?)
      puts 'NO MATCH: ' + name
      next
    end

    friendlyName = m['name']
    gender = m['gender']
    shiny = m['shiny']
    form = m['form']
    name = name[4..-5]

    case friendlyName
      when 'unown'
        friendlyName += case form
        when 'exclamation'
          ' !'
        when 'question'
          ' ?'
        when nil
          ''
        else
          ' ' + form
        end
        form = nil
      when 'nidoran', 'hippopotas', 'hippowdon'
        friendlyName += case gender
        when 'f'
          ' ♀'
        when 'm'
          ' ♂'
        else
          ''
        end
      when 'mrmime'
        'Mr. Mime'
      when 'mimejr'
        'Mime Jr.'
      when 'ho'
        friendlyName = 'Ho-Oh'
        form = nil
      when 'porygon'
        friendlyName += case form
        when 'z'
          '-Z'
        else
          ''
        end
        form = nil
      when 'shellos', 'gastrodon'
        form += ' sea'
      when 'spinda'
        form = '#' + form
      when 'basculin'
        form += ' stripe'
    end

    variant = (form.nil? ? 'normal' : form).gsub(/(\w+)/) {|s| s.capitalize}
    type = shiny.nil? ? 'normal' : 'shiny'
    friendlyName = friendlyName.gsub(/(\w+)/) {|s| s.capitalize}
    # puts [name, friendlyName, gender, shiny, form, variant, type].join(' -- ')

    caught = 0
    caught_f = 0
    caught_m = 0
    stats = nil
    if (oldJson != nil && oldJson[type][region][entry])
      stats = oldJson[type][region][entry]
    end

    if (simpleData != nil && simpleData[filename])
      stats = simpleData[filename]
    end

    if (stats != nil)
      caught = stats['caught'].to_i
      caught_m = stats['caught_m'].to_i
      caught_f = stats['caught_f'].to_i
    end

    json[type][region][entry] = {
      'number' => number,
      'name' => friendlyName,
      'variant' => variant,
      'caught' => caught,
      'caught_m' => caught_m,
      'caught_f' => caught_f
    }
    totalPokedex = totalPokedex + 1
    totalCaught = totalCaught + caught
  end
end

file = File.open("_data/pokemongo.json", "w")
file.puts(JSON.pretty_generate({
  'caught' => totalCaught,
  'total' => totalPokedex
}))
file.close

json.each do |k1,type|
  type.each do |k2,region|
    json[k1][k2] = region.sort_by { |k,v| [k.scan(/\d+/).first.to_i, v['name'], v['variant'].gsub('Alola', '~Alola'), k] }.to_h
  end
end

file = File.open("_data/pokedex.json", "w")
file.puts(JSON.pretty_generate(json))
file.close
