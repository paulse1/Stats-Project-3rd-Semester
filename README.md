# Stats-Project-3rd-Semester: Armed Conflicts in Nigeria

Authors: Danh Chau Ngo, Paul Seitz, Marc Landes, Yuxin Qiu, Shuangying Xu

## General Information

This is the repository for our 3rd semester project. Our subject was "Armed Conflicts in Nigeria".
If one just wants to see the results open summary.pdf and presentation.html in your browser.
For further information keep reading.

## Usage

Our project uses a lot of packages since we incorporated both map plotting and animation.
To ensure all packages are installed, source package_installer.R.
To then create both the summary and presentation, source source_all.R.
Be sure not to have summary.pdf opened in another program (like adobe acrobat)
before sourcing source_all.R, because it will abort right at the end because the computer 
does not change files when they are opened elsewhere and sourcing source_all.R takes 
approx. 2 minutes.
package_installer.R is deliberately not included in source_all.R, to not install packages
on the users computer unasked.

## Directory Structure

### code

Includes all .R files with code used to generate the presentation.

### data

Includes /raw where one can find the raw data used, and /intermediate where all intermediate steps
are being stored.

### output

Includes /figures for static plots and /gif for animated plots

### Other files

Other files include .gitignore, .Rhistory, and the .qmds which generate the content.
Also there is an old version of the presentation included, which does not include some of the 
supervisors feedback.
