#!/bin/bash
start=`date +%s`
input_file="sequences.txt"
output_dir="chunks"
num_chunks=$1

mkdir -p "$output_dir"

# total_lines=$(wc -l < "$input_file")
# echo $total_lines
# echo $(expr $total_lines % $num_chunks / 2)
# lines_per_chunk=$((total_lines / num_chunks))
# echo $lines_per_chunk
#split -l "$lines_per_chunk" "$input_file" "$output_dir/chunk"

total_lines=$(wc -l < "$input_file")
chunk_size=$((total_lines / num_chunks))
# Calculate the number of full chunks
full_chunks=$((total_lines / chunk_size))

# Calculate the number of remaining lines
remaining_lines=$((total_lines % chunk_size))

# Split the input file into full chunks
split -l $chunk_size "$input_file" chunks/chunk

# Append the remaining lines to the last created chunk
tail -n $remaining_lines "$input_file" >> chunks/chunkaa

#remove the additional file that was appended to the first one
num_files=$(ls -1 chunks/ | wc -l)
for file in $(ls -1 ./chunks | head -n "$num_files")
do
    if [ $(wc -l < "./chunks/$file") -lt "$chunk_size" ]
    then
        rm "./chunks/$file"
    fi
done

remove_chars() {
  local input=$1
  local output="${input//>}"
  output="${output//<}"
  echo "$output"
}

# Count the number of files in the "chunks" folder
num_files=$(ls -1 chunks/ | wc -l)
folder_path="./chunks"
final_output="alignment_output"
mkdir -p "$final_output"

# #iterate thorugh the files (slitted into N parts)
for file in $(ls -1 "$folder_path" | head -n "$num_files")
do

    python dinamic_final.py $folder_path/$file >> ./alignment_output/final$file.txt &

done

wait
end=`date +%s`

runtime=$((end-start))
echo All alignment processes ready.
echo $runtime