###

LEVEL 1B: Parallel Coordinates Visualization

The software tool at this level should be able to display the tabular data in the spreadsheet named
as “5-years” in FreqWords.xlsx using a parallel coordinates plot. The table includes 5 major data
columns, labelled as “1990-1994”, “1995-1999”, ..., “2000-2014”. Each column has 40 measured
values, that is, 40 multivariate data objects (with five variables). In addition to the five numerical
values, each data object is associated with a nominal value, representing a frequently-occurred
word.

Your software must have the following essential functionality:

 - Display a line for each of the k (20  k  40) data objects, intersecting with the 6 axes at correct places. If you choose k < 40, it is recommended to use the k words with more frequent occurrence.
 - Display labels for each axis.
 - Provide a brushing utility. (Vertical brushing on all)
 - It is recommended to set all five numerical axes to the range [0, 250]. However, you may experiment with other ranges for these axes.

###

COLUMN_NAMES = ['1990-1994', '1995-1999', '2000-2004', '2005-2009', '2010-2014']

d3.csv('FreqWords5Year.csv')
  .row( (rawRow) ->
    (['sum'].concat COLUMN_NAMES).map (columnName) ->
      rawRow[columnName] = parseInt(rawRow[columnName], 10)
    rawRow
  )
  .get((error, rows) ->
    # initialisation stuff
    WIDTH = 800
    HEIGHT = 380

    svg = d3.select('#visualisation2').style
      width: WIDTH
      height: HEIGHT
      background: 'white'
      border: '1px solid #333'

    g = svg.append('g').attr('transform', 'translate(100,100)')

    # project data
    grouped = {}
    for colName in COLUMN_NAMES
      grouped[colName] = rows.map((row) -> row[colName]).sort().reverse()

    # draw the vertical axes
    min = d3.min(rows, (row) -> d3.min(COLUMN_NAMES.map (colname) -> row[colname]))
    max = d3.max(rows, (row) -> d3.max(COLUMN_NAMES.map (colname) -> row[colname]))

    console.log 'min', min, 'max', max

    verticalScale = d3.scale.linear()
      .domain([min,max])
      .range([0, 500])

    horizontalScale = d3.scale.linear().domain([0,4]).range([0,580])

    verticalOrderingScale = d3.scale.linear()
      .domain([0, rows.length - 1])
      .range([0, 500])

    colourScale = d3.scale.category20c().domain([36,1000]) # for sum attribute

    axis = d3.svg.axis()
      .scale(verticalOrderingScale)
      .orient('right')

    # draw the actual lines
    # lineData = (row) -> for i in [0..4]
    #   x: i
    #   y: row[COLUMN_NAMES[i]]

    rankingData = (row) -> for i in [0..4]
      x: i
      y: grouped[COLUMN_NAMES[i]].indexOf row[COLUMN_NAMES[i]]

    g.selectAll('path')
      .data(rows)
      .enter()
      .append('path')
      .attr(
        'd': (row) ->
          (d3.svg.line()
            .interpolate('cardinal')
            .tension(0.8)
            # .interpolate('linear')
            .x (d) -> horizontalScale(d.x)
            .y (d) -> verticalOrderingScale(d.y)
          )(rankingData(row))
        'stroke': (row) -> colourScale(row.sum)
        'stroke-width': 1.8
        'fill': 'none'
      )

    # draw on axes
    for i in [0..4]
      g.append('g')
        .attr('transform', 'translate(' + horizontalScale(i) + ',0)')
        .call(axis)

    # auto set visualisation height
    {height} = g[0][0].getBBox()
    svg.style
      height: height + 200

    return
  )

