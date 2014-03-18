getModelList = (e) ->
  target = $(e.target)
  year = target.parents('.selectors').find('select.year-select').val()
  model_list = target.parents('.selectors').find('.model-select-contain')
  mnfg = target.parents('.selectors').find('select.manufacturer-select').val()  
  
  # if (mnfg.length * year.length) != 0
  #   url = "/?manufacturer=#{mnfg}&year=#{year}"
  #   $.ajax
  #     type: "GET"
  #     url: url
  #     success: (data, textStatus, jqXHR) ->
  #       setModelList(model_list, data)
  if mnfg.length != 0
    url = "/?manufacturer=#{mnfg}"
    $.ajax
      type: "GET"
      url: url
      success: (data, textStatus, jqXHR) ->
        setModelList(model_list, data)
  else
    model_list.fadeOut 'fast', ->
      model_list.empty()

getBike = (e) ->
  target = $(e.target)
  model = target.parents('.selectors').find('select.model-select').val()
  return true unless model.length > 0
  # year = target.parents('.selectors').find('select.year-select').val()
  mnfg = target.parents('.selectors').find('select.manufacturer-select').val()
  year = model.substring(0,4)
  url = "/?manufacturer=#{mnfg}&year=#{year}&frame_model=#{model.slice(5)}"
  $.ajax
    type: "GET"
    url: url
    success: (data, textStatus, jqXHR) ->
      updateModelDisplay(target.parents('section'),data)
    
updateModelDisplay = (target, data=[]) ->
  fields = ['.bikebase','.frameandfork','.drivetrainandbrakes','.wheels','.additionalparts']
  for field in fields
    target.find("#{field} dl").fadeOut 'fast'
    target.find("#{field} dl").empty()
  bike = data["bike"]
  target.find('h2').html("#{bike["frame_model"]} <small>by #{bike["manufacturer"]} (#{bike["year"]})</small>")
  photo = target.find('.image-holder')

  photo.find('img').fadeOut 'fast', ->
    photo.find('.model-photo').remove()
    if bike["stock_photo_small"] != undefined
      photo.append("<a class='model-photo' href='#{bike["stock_photo_url"]}'><img src='#{bike["stock_photo_small"]}'></a>")
      photo.find('.model-photo').fadeIn("medium")
      # setTimeout(photo.find('.model-photo').fadeIn("fast"),500)
    else
      photo.find('img').fadeIn()
  
  target.find(".bikebase p").html("#{bike['description']} (<a href='#{bike["manufacturers_url"]}'>manufacturer's page</a>)")
  if bike['rear_wheel_bsd'] != undefined
    desc = ''
    if bike['rear_tire_narrow'] != undefined
      desc = "Fat "
      desc = "Narrow " if bike['rear_tire_narrow']
    desc += bike['rear_wheel_bsd']
    target.find(".bikebase dl").append("<dt>tires</dt><dd>#{desc}</dd>")
  
  for key in ['paint_description', 'original_msrp', 'cycle_type']
    if bike[key] != undefined
      c = "<dt>#{key.replace(/_/g, ' ')}</dt><dd>#{bike[key]}</dd>" 
      target.find(".bikebase dl").append(c)

  for comp in data["components"]
    name = comp["component_type"].replace(/_/g, ' ')
    if comp["front_or_rear"] == "both"
      name += "s"
    else if comp["front_or_rear"] == "front"
      name = "front #{name}"
    else if comp["front_or_rear"] == "rear"
      name = "rear #{name}"
    dlgroup = comp["cgroup"].replace(/\s+/g,'').toLowerCase()
    c = "<dt>#{name}</dt><dd>#{comp["description"]}</dd>"
    target.find(".#{dlgroup} dl").append(c)

  for field in fields
    if target.find("#{field} dd").length > 0
      target.find("#{field}, #{field} dl").fadeIn()
    else
      target.find("#{field}").fadeOut()

setModelList = (target, data=[]) ->
  selects = "<select class='model-select'><option value=''>Select a model</option>"
  # for year in years
  #   models = "<optgroup label='#{year}'>"
  for year in Object.keys(data)
    selects += "<optgroup label='#{year}'>"
    for model in data[year]
      selects += "<option value='#{year} #{model}'>#{year} #{model}</option>"
    selects += "</optgroup>"
  # for model in year
  #   selects += "<option value='#{model}'>#{model}</option>"
  # models.push({text: name, id: name})
  # selects.push({ title: year, children: models })
  target.html(selects + "</select>")
  target.find('select')
    .select2()
    .on "change", (e) ->
      getBike(e)
  target.fadeIn('fast')
    


$(document).ready ->
  $('.manufacturer-select, .year-select').on "change", (e) ->
    getModelList(e)

  $('select').select2()