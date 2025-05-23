/*
Project Title: projectPalindromePlayBuf
Date: Wed Jan 29 16:32:10 2025

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


/*
DESCRIBE project here

*/

// post project files & folders
(
	"Files & folders in this project:\n".postln;
	PathName.new(
		Document.current.dir
	).streamTree(Post, 1);
	"".postln
);