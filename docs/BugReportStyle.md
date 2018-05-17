# Bug Reports and Feature Requests

### Bug Reports

Your goal in submitting a bug report is to get the bug fixed. This means giving the developers a concise description of the bug and a way to reproduce it. Bug reports are not complaints or requests for new functionality. Rather, they describe a way in which the software does not behave as intended. Here are some specific issues to consider.

* List only one bug per report. Do not submit a report that is a bullet list of issues. If you find yourself making a list, just submit each part of the list as a separate bug. 

* Tag the bug as "Critical" if it is holding back a significant number of users and there is no work around. Otherwise, just tag it as a bug. Note that the developers may downgrade or upgrade the criticality of the bug after you submit it.

* Be clear and concise. If the developers do not understand your report, your report may be ignored or rejected.

* Explain exactly how to reproduce the bug. For example, if a button doesn't work, then say which button it is, what page it is one, what state the UI is in when the button can be observed not to work (if that matters), etc.

* Write minimum reproducible code. If a 300 line protocol does not work, please don't report a bug that says: Protocol such and such crashes with a runtime error at line 89. Instead, write a new protocol in which you remove everything from the protocol except the lines that illustrate the bug. Such a protocol is a "minrep" and can sometimes be as few as five lines long. Point the programming team to that minrep in your bug report and say what the code *should* do and what it *actually does*.

* Be polite. Remember that the bug you are reporting is a byproduct of a feature that was lovingly coded by a real human who's goal is to make nice softare for you to use every day.

### Feature Requests

Feature requests can be helpful to the programming team in certain cases. The most useful are ones that describe a way in which the user experience or functionality of the software could be improved in a way that is consistent with the direction the software development is already going. User interface improvements, for example, are helpful, especially when you notice a user going back and forth a lot imn the UI, getting lost in the UI, or writing things down on paper that the software should be keeping track of. Core functionality feature requests can sometimes be helpful or sometimes be so far afield from what the software does that it is more of a pie-in-the-sky request. Worse is a feature request that is essentially impossible to address, like: "the software should use a graph database instead of MySQL". Feature requests requiring rework of core architecture decisions are rarely helpful. Here are some specific issues to consider.

* Describe the feature succinctly and explain who it would help and why. Describe what users do to work around the lack of the feature.

* Ask yourself if there could be more than one way to implement the feature. Allow the developers to use their intimate knowledge of the osftware to address your feature request, possibly in a completely different way than you envisioned. That is, stick to what *functionality* you want to see and not a specifc implementation of that functionality.

* Consider talking directly to the developers about your feature request. They often have long term plans for the software and your feature may either be addressed or obviated by a future release. In this case, you may want to become a beta tester for the new release and submit feature requests to *that* release. 

* Be polite. Remember that the feature you are requesting by definition exposes a way in which the software is problematic. Remember to phrase requests as requests not demands. Say "It would be nice if ..." as opposed to "The software should ...". Both get your message accross, but that former is much more likley to get a response from the developers.