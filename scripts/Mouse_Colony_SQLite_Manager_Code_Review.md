# Mouse Colony SQLite Manager: Code Review and Deployment Notes

## Files reviewed

This project contains three Python scripts:

```text
database_manager.py
gui.py
main.py
```

The application is a local SQLite-based mouse colony inventory manager with a PyQt5 graphical interface.

---

# 1. `database_manager.py`

## Purpose

`database_manager.py` is the database backend for the application. It defines the SQLite database filenames, table schema, and all core database operations used by the GUI and startup script.

## Database files defined

The script defines five SQLite database files:

```text
ROOM_428.db
EUTHANIZED.db
ROOM_203B.db
NR1.db
BREEDERS.db
```

All databases use the same table name:

```text
mouse_list
```

## Table schema

The table is created with the following columns:

```text
INDEX_ID
ID_TATOO_NT
CAGE_NUM
MOUSELINE
GENOTYPE
GENDER
DOB
AVAILABLE
HEALTH
USER_NAME
MANIPULATIONS
EXPERIMENT_1
EXPERIMENT_2
EXPERIMENT_3
EXPERIMENT_4
EXPERIMENT_5
STATUS
COMMENTS
```

`INDEX_ID` is the SQLite autoincrement primary key.

## Main functions

### `initialize_database(db_file)`

Creates the `mouse_list` table in a specified database file if the table does not already exist.

### `create_empty_database()`

Creates empty versions of:

```text
EUTHANIZED.db
ROOM_203B.db
BREEDERS.db
NR1.db
```

This function does not initialize `ROOM_428.db` in its loop, because `ROOM_428.db` is intended to be populated from the CSV import workflow.

### `load_csv_to_dataframe(csv_file)`

Loads a CSV file into a pandas DataFrame.

### `save_dataframe_to_sqlite(df, db_file, table_name="mouse_list")`

Appends a pandas DataFrame into the selected SQLite table.

### `fetch_data(db_file)`

Reads all mouse records from a selected database and returns them as a pandas DataFrame. It excludes `INDEX_ID` from the returned table.

### `filter_records(db_file, column, value)`

Filters records from a selected database by a specified column and value. In the GUI, this is used to search by `MOUSELINE`.

### `export_to_csv(db_file, csv_filename)`

Exports the selected database table to a CSV file, excluding `INDEX_ID`.

### `insert_record(...)`

Adds a new mouse record to the selected database.

### `update_record(...)`

Updates an existing mouse record using `INDEX_ID`.

### `delete_record(db_file, id_tatoo_nt)`

Deletes a record using `ID_TATOO_NT`.

### `copy_row_to_new_db(source_db, destination_db, id_tatoo_nt)`

Copies one mouse record from one database file to another using `ID_TATOO_NT`.

## Important code behavior

- The same schema is repeated in multiple places.
- `fetch_data()`, `filter_records()`, and `export_to_csv()` intentionally exclude `INDEX_ID`.
- `update_record()` updates by `INDEX_ID`, but the GUI must look up `INDEX_ID` using `ID_TATOO_NT` first.
- `save_dataframe_to_sqlite()` uses `if_exists="append"`, so running the CSV import repeatedly can append duplicate rows unless the database is deleted or cleared first.

---

# 2. `gui.py`

## Purpose

`gui.py` defines and launches the PyQt5 graphical user interface for viewing and editing the mouse colony databases.

The main class is:

```python
DatabaseApp(QWidget)
```

The GUI allows the user to interact with the SQLite databases without writing SQL commands.

## Main GUI features

### Database selector

A dropdown menu allows switching between:

```text
ROOM_428
EUTHANIZED
ROOM_203B
BREEDERS
NR1
```

Changing the selection reloads the table from the selected database.

### Search

The GUI includes a search box and search button.

Current behavior:

```text
Search filters by MOUSELINE.
```

### Table view

The main table displays database records using `QTableWidget`.

Features:

```text
sortable columns
row selection
automatic loading from selected database
```

The displayed table excludes `INDEX_ID`.

### Export

The `Export to CSV` button opens a file dialog and exports the currently selected database to CSV.

### Copy row

The `Copy Row` button copies the selected row from the current database to another selected database.

This supports workflows such as moving/copying a mouse record to:

```text
EUTHANIZED
BREEDERS
NR1
ROOM_203B
```

### Add record

The form fields at the bottom of the GUI allow adding a new record to the currently selected database.

### Update row

Selecting a row fills the form fields. The user can edit values and click `Update Row`.

The GUI looks up the hidden `INDEX_ID` from the database using `ID_TATOO_NT`, then calls `update_record()`.

### Delete row

The `Delete Row` button deletes the selected record using `ID_TATOO_NT`.

## Important code behavior

- `run_gui()` calls `create_empty_database()` before starting the PyQt application.
- The table displays records without `INDEX_ID`, but updates still depend on looking up `INDEX_ID`.
- The search function is currently limited to exact matching of `MOUSELINE`.
- The code contains an indentation issue in the uploaded version near the loop:

```python
for label in labels:
```

In the uploaded file, this line appears over-indented. As written, that would likely cause a Python `IndentationError` unless corrected.

---

# 3. `main.py`

## Purpose

`main.py` is the startup/import script.

It is intended to initialize database files, import the initial colony CSV into `ROOM_428.db`, and then launch the GUI.

## Main behavior

When run directly:

```bash
python main.py
```

the script does the following:

1. Imports database functions and constants from `database_manager.py`.
2. Imports `run_gui()` from `gui.py`.
3. Defines the CSV file:

```text
PPL_Scholl_428_MouseList.csv
```

4. Initializes all five database files:

```text
ROOM_428.db
EUTHANIZED.db
ROOM_203B.db
BREEDERS.db
NR1.db
```

5. Initializes `ROOM_428.db` again.
6. If the CSV file exists, loads it with pandas and appends it into `ROOM_428.db`.
7. If the CSV file is missing or import fails, it starts with an empty database.
8. Launches the GUI.

## Important code behavior

- The CSV import is append-based.
- If `main.py` is run multiple times without deleting or clearing `ROOM_428.db`, the CSV rows may be duplicated.
- `main.py` is best used for initial database creation/import.
- For normal daily use with existing databases, launching `gui.py` directly is safer.

---

# Recommended usage workflow

## Initial setup from CSV

Use this only when creating the databases from the original CSV inventory.

```bash
python main.py
```

This initializes the SQLite database files and imports:

```text
PPL_Scholl_428_MouseList.csv
```

into:

```text
ROOM_428.db
```

## Routine use

After databases already exist, run:

```bash
python gui.py
```

This opens the GUI and uses the existing `.db` files.

---

# Creating a deployable Windows executable

## 1. Create or activate a Python environment

Example:

```bash
python -m venv colony_env
colony_env\Scripts\activate
```

## 2. Install required packages

The code requires:

```bash
pip install pandas PyQt5 pyinstaller
```

## 3. Confirm the app runs before building

Run:

```bash
python gui.py
```

Confirm that the GUI opens and that the database files are found.

## 4. Build the executable

Use PyInstaller:

```bash
pyinstaller --onefile --windowed gui.py
```

This creates:

```text
dist/gui.exe
```

## 5. Prepare deployment folder

Place the executable and database files together in one folder:

```text
MouseColonyApp/
    gui.exe
    ROOM_428.db
    EUTHANIZED.db
    ROOM_203B.db
    BREEDERS.db
    NR1.db
```

Because the code uses relative database filenames, the `.db` files should be in the same working folder as the executable.

## 6. Deploy from Google Drive Desktop

If Google Drive Desktop is installed and mounted in Windows Explorer, the deployment folder can be placed somewhere like:

```text
G:\My Drive\MouseColonyApp\
```

or another Google Drive Desktop path.

Run:

```text
gui.exe
```

from that folder.

## Important SQLite + Google Drive caution

SQLite is safest when only one user/computer edits the database at a time.

Avoid opening or editing the same database simultaneously from multiple computers, because cloud sync tools can create conflicted copies or corrupt a live SQLite database.

Recommended practice:

```text
Use one active editing computer at a time.
Close the app before allowing Drive to sync.
Keep dated backups of the .db files.
```

---

# GitHub version control recommendation

Track code files:

```text
database_manager.py
gui.py
main.py
README.md
requirements.txt
```

Usually do not track live database files unless you intentionally want a snapshot:

```text
*.db
```

Suggested `.gitignore` entries:

```text
__pycache__/
*.pyc
*.db
dist/
build/
*.spec
exports/
backups/
```

If the database contents are important, keep backups separately from GitHub or store sanitized database snapshots only when appropriate.

---

# Summary

This project is a local PyQt5 desktop application for managing a mouse colony inventory stored in multiple SQLite database files.

- `database_manager.py` contains the database schema and backend operations.
- `gui.py` contains the PyQt5 user interface for browsing, searching, editing, exporting, deleting, and copying records.
- `main.py` initializes databases, imports the initial CSV into `ROOM_428.db`, and launches the GUI.

For normal use, run `gui.py` or a PyInstaller-built `gui.exe` with the `.db` files in the same folder.
