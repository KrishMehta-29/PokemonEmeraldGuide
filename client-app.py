"""
Student name(s): Krish Mehta, Leo Yang
Student email(s): kmmehta@caltech.edu lyang3@caltech.edu
"""
import sys  # to print error messages to sys.stderr
import mysql.connector
# To get error codes from the connector, useful for user-friendly
# error-handling
import mysql.connector.errorcode as errorcode
import os


DEBUG = True


# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """

    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='appadmin',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',  # this may change!
          password='adminpw',
          database='final' # replace this with your database name
        )

        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database; hence the DEBUG use.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            # A fine catchall client-facing message.
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)

def get_conn_user():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='appclient',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',  # this may change!
          password='clientpw',
          database='final' # replace this with your database name
        )
        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database; hence the DEBUG use.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            # A fine catchall client-facing message.
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)

# ----------------------------------------------------------------------
# Functions for Command-Line Options/Query Execution
# ----------------------------------------------------------------------

def execute_sql(conn, sql, error, commit=False):
    conn.reconnect()
    cursor = conn.cursor()
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        
        if commit:
            conn.commit()

        os.system('cls')
        return rows
       
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr(error)

def catch_pokemon(userConn, pid, pkmn):
    sql = f"CALL add_pkmn_to_pc({pid}, '{pkmn.lower()}');"
    rows = execute_sql(userConn, sql, "An error occured, please provide valid pokemon name", commit=True)
    print("Successfully added to box")

def show_box(userConn, pid):
    sql = f'SELECT pkmn_name, count FROM pc NATURAL JOIN pokemon WHERE player_id={pid};' 
    rows = execute_sql(userConn, sql, "An error occured, box cannot be displayed")
    print("Owned Pokemon: \n")
    
    print(f"Pokemon \t \t Count")
    print("-------- \t \t -----")

    for row in rows:
        print(f"{row[0].ljust(20)} \t {row[1]}")

def find_best_pkmn(userConn, pid):
    sql = f"CALL getBestPokemon({pid});" 
    rows = execute_sql(userConn, sql, "An error occured, best pokemon not available")

    print("Best Available Pokemon to Catch: \n")
    print("Pokemon Name")
    print("------------")
    for row in rows:
        print(f"{row[1]}")

def find_best_box_pkmn(userConn, pid):
    sql = f"CALL choose_team({pid});" 
    rows = execute_sql(userConn, sql, "An error occured, best box pokemon not available")

    print("Best Available Pokemon From Box (Only supereffective): \n")
    print("Pokemon Name")
    print("------------")
    for row in rows:
        print(f"{row[0]}")

def get_pid(userConn, username):
    sql = f"SELECT getPid('{username}');"
    rows = execute_sql(userConn, sql, "An error occured, pid not available")
    return rows[0][0]

def findAllPokemonOnLocation(userConn, route):
    sql = f"CALL findAllPokemonOnLocation('{route}');" 
    rows = execute_sql(userConn, sql, "An error occured, check name of route")

    print(f"All pokemon available at {route}: \n")

    print("Pokemon")
    print("-------")
    for row in rows:
        print(row[0])

def findAllLocations(userConn, pid):
    sql = f"CALL find_accessible_locations({pid});"
    rows = execute_sql(userConn, sql, "An error occured, routes not available")

    print(f"All Available Locations: \n")

    print("Location")
    print("--------")
    for row in rows:
        print(row[0])

def findAllCatchablePokemon(userConn, pid):
    sql = f"CALL getAvailablePkmn({pid});"
    rows = execute_sql(userConn, sql, "An error occured, routes not available")

    print("Pokemon")
    print("-------")
    for row in rows:
        print(row[0])

def nextGym(userConn, pid):
    sql = f"SELECT username, next_gym FROM player WHERE player_id={pid};"
    rows = execute_sql(userConn, sql, "An error occured, cannot get info")

    print(f"Username: {rows[0][0]}")
    print(f"Next Gym: {rows[0][1]}")

def updateGym(userConn, pid, gymNo):
    sql = f"CALL update_gym({pid}, {gymNo});"
    rows = execute_sql(userConn, sql, "An error occured, provid valid gym", commit=True)

    for row in rows:
        print(row) 

# ----------------------------------------------------------------------
# Functions for Logging Users In
# ----------------------------------------------------------------------
# Note: There's a distinction between database users (admin and client)
# and application users (e.g. members registered to a store). You can
# choose how to implement these depending on whether you have app.py or
# app-client.py vs. app-admin.py (in which case you don't need to
# support any prompt functionality to conditionally login to the sql database)

def log_in(username, pwd):
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = f"SELECT authenticate('{username}', '{pwd}');"
    try:
        cursor.execute(sql)
        row = cursor.fetchone()
        
        if row[0]:
            print("Successful Login")
            pid = get_pid(conn, username)
            

            user_conn = get_conn_user() # Getting the user connection
            controlLoop(pid, user_conn)

        else:
            print("Unsuccessful Login")
            show_options_login()
        
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')

def create_user(username, pwd):
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    sql = f"CALL sp_add_user('{username}', '{pwd}');"
    
    print(username, pwd)

    try:
        cursor.execute(sql)
        print("Executing SQL")
        conn.commit()
        # row = cursor.fetchone()
        pid = get_pid(conn, username)
        user_conn = get_conn_user()
        controlLoop(pid, user_conn)
            
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')

# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------

def controlLoop(pid, userConn):
    while True:
        show_options(pid, userConn)

def show_options_login():
    """
    Displays options users can choose in the application, such as
    viewing <x>, filtering results with a flag (e.g. -s to sort),
    sending a request to do <x>, etc.
    """

    os.system('cls')

    print('Welcome to our Pokemon Emerald Guide App. This app suggests the best pokemon you can use at each gym leader. Enter the pokemon you catch, and as you progress the game, and use the functions provided to get infomration about the best pokemon that you can catch! \n')

    print('What would you like to do?\n')
    print('login [username] [password]') 
    print('create [username] [password]')
    print('q - quit')
    print()
    ans = input('\nEnter an option: ').lower()

    ansParts = ans.split(" ")

    if ansParts[0] == 'q':
        quit_ui()

    elif ansParts[0] == 'login' and len(ansParts) == 3:
        log_in(ansParts[1], ansParts[2])

    elif ansParts[0] == 'create' and len(ansParts) == 3:
        create_user(ansParts[1], ansParts[2])

def show_options(pid, userConn):
    """
    Displays options users can choose in the application, such as
    viewing <x>, filtering results with a flag (e.g. -s to sort),
    sending a request to do <x>, etc.
    """
    os.system('cls')

    print('What would you like to do?\n')
    print('my info - Returns the current users information')
    print('update gym [gym_no] - Sets the next gym to the gym_no for the user')
    print('catch [pokemon] - Adds the pokemon to the users box') 
    print('show box - Shows all the pokemon caught by the user')
    print('find best pokemon - Finds the best possible pokemon available for the next gym')
    print('find best box pokemon - Finds the best possible pokemon that have been caught for the next gym')
    print('accessible locations - Finds all the accessible locations')
    print('location [location] - Finds all catchable pokemon at the [location]')
    print('accessible pokemons - Finds all pokemon accessible')
    print('q - quit')

    ans = input('\nEnter an option: ').lower()

    # Prevents SQL injection by splitting input string into individual words
    ansParts = ans.split(" ")

    if ansParts[0] == 'q' and len(ansParts) == 1:
        quit_ui()
    
    elif ansParts[0] == 'my' and ansParts[1] == 'info' and len(ansParts) == 2:
        nextGym(userConn, pid)

    elif ansParts[0] == 'update' and ansParts[1] == 'gym' and len(ansParts) == 3:
        updateGym(userConn, pid, int(ansParts[2]))

    elif ansParts[0] == 'catch' and len(ansParts) == 2:
        catch_pokemon(userConn, pid, ansParts[1])

    elif ansParts[0] == 'show' and ansParts[1] == 'box' and len(ansParts) == 2:
        show_box(userConn, pid)

    elif ansParts[0] == 'find' and ansParts[1] == 'best' and ansParts[2] == 'pokemon' and len(ansParts) == 3:
        find_best_pkmn(userConn, pid)

    elif ansParts[0] == 'find' and ansParts[1] == 'best' and ansParts[2] == 'box' and ansParts[3] == 'pokemon' and len(ansParts) == 4:
        find_best_box_pkmn(userConn, pid)

    elif ansParts[0] == 'accessible' and ansParts[1] == 'locations' and len(ansParts) == 2:
        findAllLocations(userConn, pid)
    
    elif ansParts[0] == 'location' and len(ansParts) > 1:
        inp = ansParts[1:]
        findAllPokemonOnLocation(userConn, " ".join(inp))

    elif ansParts[0] == 'accessible' and ansParts[1] == 'pokemons' and len(ansParts) == 2:
        findAllCatchablePokemon(userConn, pid)

    input("\nPress Enter to Continue")

def quit_ui():
    """
    Quits the program, printing a good bye message to the user.
    """
    print('Good bye!')
    exit()


def main():
    """
    Main function for starting things up.
    """
    show_options_login()


if __name__ == '__main__':
    # This conn is a global object that other functions can access.
    # You'll need to use cursor = conn.cursor() each time you are
    # about to execute a query with cursor.execute(<sqlquery>)
    conn = get_conn()
    main()
