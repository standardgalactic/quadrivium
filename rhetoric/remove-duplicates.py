import os

def remove_duplicate_lines_from_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    cleaned_lines = []
    prev_line = None
    for line in lines:
        if line != prev_line:
            cleaned_lines.append(line)
        prev_line = line

    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(cleaned_lines)


def process_txt_files_in_directory():
    for filename in os.listdir('.'):
        if filename.endswith('.txt'):
            print(f'Processing: {filename}')
            remove_duplicate_lines_from_file(filename)


if __name__ == "__main__":
    process_txt_files_in_directory()
