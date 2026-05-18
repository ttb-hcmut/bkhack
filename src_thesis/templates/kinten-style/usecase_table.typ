/// Creates the step-activity for the Ordinary sequence
///
/// # Arguments
/// - `input`: ([activity]) array for the list of steps to the Ordinary sequence
///
/// # Returns
/// The step-activity table for Ordinary sequence
#let sequence(input:()) = {
  let output = ()
  if (input.len()>0) {
      let rowcount = 1
      let steps = ()
      steps.push([*Step*])
      steps.push([*Activity*])

      for activity in input {
        steps.push([#rowcount])
        steps.push([#activity])
        rowcount+=1
      }
      output.push(table.cell(rowspan: rowcount)[Ordinary Sequence])
      output += steps
  }
  else { 
    output.push([Ordinary Sequence])
    output.push(table.cell(colspan: 2)[None])
  }
  output
}


/// Creates the step-activity for the Exceptions
///
/// # Arguments
/// - `input`: ("step#":[activity],"step#":[activity]) dictionary for the step number that has an exception
///
/// # Returns
/// The step-activity table for Exceptions
#let exception(input:(([],[]))) = {
  let output = ()
  if (input.len()>0) {
      let rowcount = 1
      let steps = ()
      steps.push([*Step*])
      steps.push([*Activity*])

      for (key,activity) in input {
        steps.push([#key])
        steps.push([#activity])
        rowcount+=1
      }
      output.push(table.cell(rowspan: rowcount)[Exceptions])
      output += steps
  }
  else { 
    output.push([Exceptions])
    output.push(table.cell(colspan: 2)[None])
  }
  output
}

/// Constructs a usecase's description table
///
/// # Arguments
/// - `id`: [] content block for the Usecase ID, default: [UCID]
/// - `name`: [] content block  for Usecase name, default: [Usecase name]
/// - `dep`: [] content block for Dependencies, default: [None]
/// - `pre`: [] content block for Prerequisite conditions, default: [None]
/// - `seq`: ([activity],[activity]) array of content blocks for Ordinary sequence, default: () (displays as [None])
/// - `post`: [] content block for Post conditions, default: [None]
/// - `except`: (([step#],[activity]),([step#],[activity])) dictionary for Exceptions, default: () (displays as [None])
/// - `comment`: [] content block for comments, default: [None]
///
/// # Returns
/// A usecase description table
#let usecase-desc-table(
  id:[UCID],
  name:[Usecase name],
  dep:[None],
  desc:[None],
  pre:[None],
  seq:(),
  post:[None],
  except:(),
  comment:[None],
) = {
  table(
    columns: (25%, 10%, 65%),
    inset: 10pt,
    align: left,
    table.header(
      [*#id*], table.cell(colspan: 2)[*#name*]
    ),
    [Dependencies], table.cell(colspan: 2)[#dep],
    [Description], table.cell(colspan: 2)[#desc],
    [Precondition], table.cell(colspan: 2)[#pre],
    ..sequence(input:seq),
    [Post Condition], table.cell(colspan: 2)[#post],
    ..exception(input:except),
    [Comments], table.cell(colspan: 2)[#comment],
  )
}

// example usage
// #usecase-desc-table(
//   seq:(
//     [sigma],
//     [sigma],
//     [boy],
//     [sigma],
//     [boy],
//   ),
//   except:(
//     ([6],[sigma]),
//     ([6],[sigma]),
//     ([6],[sigma]),
//     ([6],[sigma]),
//     ([6],[sigma]),
//   )
// )