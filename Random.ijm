/*
 *  BlindAnalysis.ijm
 *  This macro will take a directory of TIFFs
 *  	strip the label from them
 *  	save each with a randomised filename
 *  	log the association between original file and blind analysis file
 *  Adapted from:
 *  Shuffler macro by Christophe Leterrier v1.0 26/06/08
 *  Modified by Chris Gell 07/09/2018 Adapted from https://github.com/quantixed/imagej-macros/blob/master/Blind_Analysis.ijm
 *  Only works with .tif files and only parses subfolders of the selected folder. All subfolders must have a tif in them.
*/

macro "Blind Analysis" {
	DIR_PATH=getDirectory("Select a directory");

	rootDIR_PATH=DIR_PATH

print("\\Clear");
print("root DIR_PATH :"+DIR_PATH);

containsRandoms=newArray(1000);


	// Create the output folder
	OUTPUT_DIR=rootDIR_PATH+"BLIND"+File.separator;
	File.makeDirectory(OUTPUT_DIR);
	f=File.open(OUTPUT_DIR+"log.txt");



	rootALL_NAMES=getFileList(DIR_PATH);

totalNumImages=rootALL_NAMES.length;
	
	//////////////////// parse through the subfolder
	for (j=0; j<rootALL_NAMES.length; j++) {

		print(rootALL_NAMES[j]);

			//one of the subfolders will be the blind one for the results, need to check to make sure that is not analysed.
			if (indexOf(rootALL_NAMES[j], "BLIND") !=-1) {
        		j++;
        		print("its the blind");
        	}
        
        if (endsWith(rootALL_NAMES[j], "/")) {

        

			newDIR_PATH = DIR_PATH + rootALL_NAMES[j];
			DIR_PATH=newDIR_PATH;
		// Get all file names
		ALL_NAMES=getFileList(DIR_PATH);

		print("DIR_PATH :"+DIR_PATH);
		currentPass=j;
		processSubs();
		DIR_PATH=rootDIR_PATH;
	


        }

           
     }


//added in this functionality to parse one level of sub folders
function processSubs() {

	// How many TIFFs do we have? Directory could contain other directories.
	for (i=0; i<ALL_NAMES.length; i++) {
 		if (indexOf(toLowerCase(ALL_NAMES[i]), ".tif")>0) {
 			IM_NUMBER=IM_NUMBER+1;
 		}
 	}
	IM_NAMES=newArray(IM_NUMBER);
	IM_EXT=newArray(IM_NUMBER);

	// Test all files for extension
	j=0;
	for (i=0; i<ALL_NAMES.length; i++) {
		if (indexOf(toLowerCase(ALL_NAMES[i]), ".tif")>0) {
			IM_NAMES[j]=ALL_NAMES[i];
			j=j+1;
		}
	}

	// Generate a permutation array of length IM_NUMBER
	IM_PERM=newArray(IM_NUMBER);
	for(j=0; j<IM_NUMBER; j++) {
		IM_PERM[j]=j+1;
	}
	for(j1=0; j1<IM_NUMBER; j1++) {
		j2=floor(random*IM_NUMBER);
		swap=IM_PERM[j1];
		IM_PERM[j1]=IM_PERM[j2];
		IM_PERM[j2]=swap;
	}

	// Associate sequentially permuted positions to image names
	IM_PERM_NAMES=newArray(IM_NUMBER);
	for(j=0; j<IM_NUMBER; j++){

		randomNumber=round(random*1000000); //generate a random number

		//this does a quick check to make sure that file name is not already in use, have to think of a better way of doing this. Right now it just does it again, chances are then very low.
		for(p=0; p<999; p++) {
			if (randomNumber == containsRandoms[p]) {
			randomNumber=round(random*1000000);
		}
		}
		
		IM_PERM_NAMES[j]="blind_"+randomNumber; // 
	//Need to include a test here as names could be reused, although this is somewhat unlikely.

		
	}

	// Open each image (loop on IM_NAMES) and save them in the destination folder
	// as the blinded file (IM_PERM_NAME).
	// Additionally logs both names in the log.txt file created in the destination folder
	setBatchMode(true);

	
	
	
	
	print(f, "Original_Name\tBlinded_Name");
	for(j=0; j<IM_NUMBER; j++){
		INPUT_PATH=DIR_PATH+IM_NAMES[j];
		OUTPUT_PATH=OUTPUT_DIR+IM_NAMES[j];
		OUTPUT_PATH_PERM=OUTPUT_DIR+IM_PERM_NAMES[j];
		open(INPUT_PATH);
		getDimensions(ww, hh, cc, ss, ff);
		if(ss > 1 || ff > 1)  {
				stripFrameByFrame(cc,ss,ff);
		} else  {
				setMetadata("Label", ""); // strips the label data from the image for blinding purposes
		}
		save(OUTPUT_PATH_PERM);
		print(f,IM_NAMES[j]+"\t"+IM_PERM_NAMES[j]);
		close();
	}
	setBatchMode("exit and display");
	showStatus("finished");

}

function stripFrameByFrame(cc,ss,ff)  {
  if(Stack.isHyperstack) {
  for(i = 0; i < ss; i++){
    Stack.setSlice(i+1);
    for(j = 0; j < ff; j++) {
      Stack.setFrame(j+1);
      for(k = 0; k < cc; k++) {
        Stack.setChannel(k+1);
        setMetadata("Label", "");
      }
    }
  }
  } else if(cc > 1 && ss == 1 && ff == 1)  {
      setMetadata("Label", "");
  } else if(cc == 1 && ss > 1)  {
      for(i = 0; i < ss; i++){
        setSlice(i+1);
        setMetadata("Label", "");
      }
  } else if(cc == 1 && ff > 1)  {
      for(i = 0; i < ff; i++){
        setSlice(i+1);
        setMetadata("Label", "");
      }
  }
}
}