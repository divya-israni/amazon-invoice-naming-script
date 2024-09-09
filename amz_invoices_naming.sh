#!/bin/bash

input_pdfs="./amazon_invoices"
output_pdfs="./new_pdfs"
output_txts="./txt_files"

mkdir -p "$output_pdfs"
mkdir -p "$output_txts"
#if directories do not alr exist 

#loop over input directory
for folder in "$input_pdfs"/*; do
	#if a folder is found
	if [ -d "$folder" ]; then
		#loop over the folder 
		for pdf_file in "$folder"/*.pdf; do
			#if you find a pdf file copy it
			if [ -f "$pdf_file" ]; then
				cp "$pdf_file" "$output_pdfs/"
			fi 
		done
	fi
done

#looping through pdf files in new_pdfs direcotry 
for pdf_file in "$output_pdfs"/*.pdf; do
#if a pdf file is there then turn it into a txt file in txt_files directory 
	if [ -f "$pdf_file" ]; then
		filename=$(basename "$pdf_file")
		filename="${filename%.*}"
		txt_file="$output_txts/${filename}.txt"
		pdftotext -layout "$pdf_file" "$txt_file"
	fi 
done

#looping through txt_files in my output folder 
for txt_file in "$output_txts"/*.txt; do
	#if there's a txt file take the name of it and save it
	#grab the order date by searching for Order Placed and then convert it to the right format
	if [ -f "$txt_file" ]; then
		filename=$(basename "$txt_file")
		filename="${filename%.*}"
		old_date=$(grep "Order Placed: " "$txt_file")
		old_date="${old_date#*Order Placed: }"
		converted_date=$(date -j -f "%B %d, %Y" "$old_date" +"%Y%m%d")
		
		#if there is a file in output_pdfs with the same name as the txt file, then set its new name 
		#begin by making a trial name with the new date and check that the file does not already exist
		if [ -f "$output_pdfs/${filename}.pdf" ]; then
			count=0
			trial_new_name="AMZ${converted_date}.pdf"
			full_path="$output_pdfs/$trial_new_name"
			#if a file exists, append a letter onto it until that file does not exist 
			while [ -f "$full_path" ]; do
				((count++))
				letter=$(printf "\x$(printf %x "$((count + 64))")")
				trial_new_name="AMZ${converted_date}${letter}.pdf"
				full_path="$output_pdfs/$trial_new_name"
			done
		
			#lastly rename pdfs in new_pdfs
			mv "$output_pdfs/${filename}.pdf" "$full_path"
		fi 
	fi
done