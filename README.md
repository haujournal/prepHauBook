Prep HAU Book Script
====================

This is a bash script used to process the `.zip` archive of the HTML version of
a book. It does three things in particular:

1. Process the HTML files to be uploaded
2. Generate a JSON file of the book's table of contents to be uploaded to a
   database
3. Generate the table of contents as a Bootstrap HTML files to be uploaded to
   the HAU Books website

Requirements
------------

The script expects the following to be installed:

1. `bash`
2. `sed`
3. `zenity` for GTK+ pop-up dialogs

Installation & Usage
-----

Clone this repository:

```
git clone git@github.com:haujournal/prepHauBook.git
```

Make the script executable:

```
chmod +x prepHauBook.sh
```

Copy the `.zip` archive to be used into the same folder and pass the archive
name to script as an argument:

```
./prepHauBook.sh example-HTML5.zip
```

A GTK+ dialog will pop up asking for the book's slug or permalink, its title,
and its author(s). It will then deposit the processed HTML and any images into
a folder named the book's permalink along with `.json` and `.html` files also
with the name of the book's permalink.

Details
-------

The `.zip` archive passed to the script is expected to have a structure similar
to the following:

```
9182938317009
├── 01_fm01.html
├── 02_fm02.html
├── 03_ch01.html
├── 04_ch02.html
├── 05_ch03.html
├── 06_ch04.html
├── ...
├── images
│   ├── ch01-01.jpg
│   ├── logo1.jpg
│   └── ...
└── template.css
```

The script removes the link to the template.css file in each of the HTML files.
It assumes this link is in one of two forms:

```html
<link rel="stylesheet" type="text/css" href="template.css"/>
```

OR

```html
<link href="template.css" type="text/css" rel="stylesheet" />
```

If it's not in one of those two, you may want to add an additional `sed`
statement or change one of the ones above.

The script then searches for any images in the HTML files and adds the
`img-responsive` and `center-block` classes to them. This enables Bootstrap to
scale them according to the user's display. It assumes any links to images
begin like so: `<img src="images`

To construct the JSON file, the script loops through a sorted list of `*.html`
files. For each file it cleans the title from within the `<title></title>`
tags, removing any final end-of-line character, and substituting three UNICODE
encoded characters with their UTF-8 equivalent:

```
&#x2019; -> ’
&#x201[dD]; -> ”
&#x201[cC]; -> “
```

It then checks if the chapter file name is `01_fm00`, `01_fm01`, `00_fm00`, or
`00_fm01`. If so, it makes the title "Front Matter".

A similar process is repeated for the HTML output file.
