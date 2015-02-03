# file assumes `d3` has already been loaded
console.log('hello')


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


d3.csv('FreqWords5Year.csv').get((error, rows) ->

  console.log(rows)
  # use `avg` property of each row as weight.

  svg = d3.select('#visualisation1')

  WIDTH = 800
  HEIGHT = 400

  svg.style(
    width: WIDTH
    height: HEIGHT
    background: '#e0e0e0'
    border: '1px solid #333'
  )


  svg.append('circle').attr(
    r: 50
    cx: 50
    cy: 50
    fill: 'red'
  )

  xScale = d3.scale.linear()
    .domain([0, 100])
    .range([0, WIDTH])

  svg.selectAll('circle')
    .data(rows)
    .enter()
    .append('circle')
    .attr('r', 10)
    .attr('cx', (r) -> xScale(r.avg))
    .attr('cy', (r) -> r.min)
    .attr('fill', 'red')

  return
)


