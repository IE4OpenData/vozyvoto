# ROADMAP for vozyvoto


## Hackathon system

To finish the hackathon system, an evaluation that computes the
percentage of error between the counts offered by the system and
actual counts is needed. (The system stays as-is, but with the error
in hand, potential users can decide whether it is useful or it is
worth waiting for the next iteration.)

* Modify the graph page to show the underlining linked data.

* Evaluate the error


## Base system

* Add the years for which the transcriptions are available but we are
  missing the attendee lists. We can use the lists of representatives
  for the given years and assume everybody was present.

* Improve the keyword distillation, possibly using titles (for
  example, of proposed new laws).

* State-of-the-Art genderizer using machine learning over all the
  Wikipedia people.

* Measure the new error counts and also error on the genderizer


## Improved system

* Text structure recognition and annotation using rules: identify
  where each speaker segment appears and who the speaker is (that is
  clear in the pages through mark-up and position).

* Evaluate the OpenNLP person finder (also known as NER) and consider
  re-training it.

* State-of-the-Art linking using machine learning over known text
  attributed to the speaker.

* Mearuse the new error counts and also the errors on the linking.


## Live system

* Daily update running on a server keeps the graph page live.

* Make the groups parameterizable by submitting custom lists on the
  graph page.


## Unabridged system

* Allows for pluggin other transcriptions by code modification (that
  is, to add a new government body, a Pull Request needs to be open
  here on GH).

* Modify the page to select the government body.

* Dynamic expansion of groups: this person was not mentioned by their
  topics were.
  

## Full system

* Add a full web UI that keeps tracks of groups and selected
  visualizations for registered users.

* The site also allows corrections of errors directly in the site.