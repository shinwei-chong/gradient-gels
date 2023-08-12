import json
import datetime
import random
import string


def generate_uid(length=6):
    characters = string.ascii_uppercase + string.digits
    return ''.join(random.choice(characters) for _ in range(length))


def get_age(dob):
    # dob should be a string in the format "dd/mm/yyyy"
    today = datetime.datetime.today()
    dob = datetime.datetime.strptime(dob, "%d/%m/%Y")
    age = today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))
    return age


def main():
    entries = []
    welcome_message = "Welcome to EMR v0.1 - {}".format(datetime.datetime.now().strftime("%d/%m/%Y"))
    print(welcome_message)

    while True:
        name = input("Enter patient's name: ")
        dob = input("Enter patient's date of birth (dd/mm/yyyy): ")
        age = get_age(dob)
        uid = generate_uid()

        entry = {
            '_uid': uid,
            'name': name,
            'dob': dob,
            'age': age
        }

        entries.append(entry)

        move_to_next = input("Move to the next entry? (Y/N): ")
        if move_to_next.lower() != 'y':
            break

    with open('patient_data.json', 'w') as json_file:
        json.dump(entries, json_file, indent=4)

    print("Patient data saved to patient_data.json")


if __name__ == "__main__":
    main()
