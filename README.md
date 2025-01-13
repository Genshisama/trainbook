# Train Booking

This project is developed for demonstration purposes only.

## Getting Started

This application is built and tested exclusively for the **Android platform**.  
Please note the following:  
- The data within the app (e.g., price, time) is **dummy data** for demonstration purposes.  
- The UI is designed to be functional but may not include comprehensive features or final polish.
- User can't preview booked ticket after finish booking process
- The return date feature is non-functional and displays the same options as the departure date. After selecting a departure seat, the process moves from train selection to seat selection and then to the summary.

## Demo

### Normal Workflow
https://github.com/user-attachments/assets/bb8cbc0c-0606-4f53-b466-de12056d4546

### Other users booking on same coach
https://github.com/user-attachments/assets/b548cc68-191c-4204-8e25-fbb7864fbba8

## Data Details

This project uses **Firebase Realtime Database** for data storage and real-time updates.  
Key points about the data structure and usage are as follows:  

- **Database Availability**:  
  - If a train or coach has never been selected, no data for it will exist in the database.  
  - Only seats that are **locked** (selected but not yet paid for) or **booked** (paid) are stored in the database.  
  - Available seats are **not** recorded in the database.  

- **Trip Representation**:  
  - Trips are written in their **full names** for display purposes, instead of using codes.

### Example Data Structure

Below is an example to illustrate the database structure:

``` json
{
  "trains": {
    "Train A": {
      "Melaka - Selangor": {
        "13 Jan Monday, 08:00 - 10:00": {
          "coaches": {
            "Coach 1": {
              "seats": {
                "A1": {
                  "lockTimestamp": "2025-01-13T12:38:05.971366Z",
                  "lockedBy": "Johnn",
                  "status": "booked"
                },
                "A2": {
                  "lockTimestamp": "2025-01-13T12:38:47.431279Z",
                  "lockedBy": "Johnn",
                  "status": "locked"
                }
              }
            }
          },
          "departureTime": "2025-01-13T22:45:00.000Z",
          "price": 35.4,
          "trainNumber": "Train A"
        }
      }
    }
  }

}
```


