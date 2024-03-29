# file assumes `d3` has already been loaded

###

LEVEL 1A: Tag Cloud Visualization

The software tool at this level should be able to display a set of tuples extracted from the
spreadsheet named as “5-years” in FreqWords.xlsx. Each tuple consists of two elements, “text”
and “weight”. Using the data sheet, one can create a list of 40 tuples using column B (rows 5-44),
and one of the columns labelled as “1990-1994”, “1995-1999”, ..., “2000-2014”. The visual
representation should be a Tag Cloud or a similar weighted word list.
Your software must have the following essential functionality:
 Display the word for each of the k (20  k  40) data tuples.
 Each word may appear in different sizes indicating the frequency of its occurrence.
 Each word should be coloured differently. Ideally colours are assigned based on a particular
property, such as “first letter”, “word length” or “frequency of occurrence”.

###

# LOAD Freq5Words.csv
# parse rows
# extract some kind of weight
# display for each of the (20 <= k <= 40) tuples??? what does this mean?


d3.csv('FreqWords5Year.csv')
  .row( (rawRow) ->
    rawRow[property] = parseInt(rawRow[property], 10) for property in ['sum', 'avg']
    rawRow
  )
  .get((error, rows) ->
    # use `avg` property of each row as weight.

    WIDTH = 800
    HEIGHT = 380
    WEIGHT_PROPERTY = 'avg'

    svg = d3.select('#visualisation1').style
      width: WIDTH
      height: HEIGHT
      background: '#e0e0e0'
      border: '1px solid #333'

    minW = d3.min(rows, (r) -> r[WEIGHT_PROPERTY])
    maxW = d3.max(rows, (r) -> r[WEIGHT_PROPERTY])

    fontSizeScale = d3.scale.linear()
      .domain([minW, maxW])
      .range([12, 50])

    colourScale = d3.scale.category20b().domain([minW, maxW])

    force = d3.layout.force()
      .charge(0)
      .size([WIDTH, HEIGHT])
      .nodes(rows)
      .charge(-150)
      .gravity(0.2)
      .on('tick', ->
        texts.attr
          x: (r) -> r.x
          y: (r) -> r.y
      )

    texts = svg.selectAll('text')
      .data(rows)
      .enter()
      .append('text')
      .text((r) -> r.word)
      .call(force.drag)
      .style(
        'font-size': (r) -> fontSizeScale(r[WEIGHT_PROPERTY]) + 'px'
        'fill': (r) -> colourScale(r[WEIGHT_PROPERTY])
        'font-family': 'impact'
      )

    force.start()

    return
  )
