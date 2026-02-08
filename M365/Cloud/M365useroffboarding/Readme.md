# How Do I Make My Microsoft 365 Off-boarding Process Quicker and Better?
An admin would definitely know how slow and error prone a manual Microsoft 365 user offboarding process is.

To simplify the work of offboarding an M365 user, we have developed a PowerShell script that makes offboarding quick and secure. With the script, you can automate 14 user offboarding best practices.

Below are the things you can do with the script:

1. Disable the user account: Block the offboarded employee from accessing their Microsoft 365 user account.
2. Reset password: Reset the password of the user to a random value.
3. Reset office name: Reset the office location of the offboarded user.
4.Remove mobile number: Remove the personal mobile number associated with the user account.
5.Remove group memberships: Strip the offboarded employee of all Microsoft 365 group memberships.
6.Remove application role assignments: Remove all application specific roles assigned to a user.
7.Remove admin roles: Remove all the administrative roles assigned to the user account.
8.Hide from address lists: Hide the user account from all address lists in your Microsoft 365 environment.
9.Remove email aliases: Remove all the email aliases associated with the user account in your environment.
10.Wipe mobile device: Remotely wipe mobile devices associated with the account.
11.Delete inbox rule: Remove all existing inbox rules set by the user.
12.Convert to shared mailbox: Change the email inbox of the user to a shared one.
13.Remove License: Revoke the Microsoft 365 license assigned to the offboarded employee.
14.Sign out from all user sessions: Easily sign out the user from all his user sessions with one click.
15.All operations: Perform all the above listed operations in one go as well.

  ## Automate Employee Offboarding in Microsoft 365 – Script Execution
The script can be executed in PowerShell with the following command:
<img width="1057" height="45" alt="image" src="https://github.com/user-attachments/assets/8123078e-a77f-4a81-bee2-a18e5c3a3d54" />

The script then prompts for the UPN (User Principal name) of the user to be off-boarded. You can also specify multiple user accounts here. Make sure to separate each UPN by a comma.

Example: **avidem@contoso.onmicrosoft.com, elara@contoso.onmicrosoft.com**

You are then prompted for the action that you need to perform. Choose **Option 15** to perform all the operations in one go.
<img width="1016" height="627" alt="image" src="https://github.com/user-attachments/assets/e0287a3e-0957-4bca-a941-116d268af3cb" />

You can also choose to carry out specific operations or their combinations by passing the respective numbers.

**Sample Output Report**
Based on the action performed and its successful completion, the following output files are generated:

**Microsoft 365 Offboarding Status Report**: ‘M365UserOffBoarding_StatusFile.csv’ contains details on the status of each operation.

<img width="873" height="547" alt="image" src="https://github.com/user-attachments/assets/b78f9f18-ab12-4d6b-ad08-ca28d82d5f8b" />

**Password Reset Log File**: ‘PasswordLogFile.txt’ contains the list of random passwords set for each user. This file is generated when the ‘Password Reset to Random’ operation is performed.
**Invalid Users Log File**: ‘InvalidUsersLogFile.txt’ contains the list of invalid UPN’s entered.

## How Microsoft 365 Offboarding Can Be Made Even Quicker and Safer?
**1. Offboard bulk Microsoft 365 users at once (Import CSV)**
Sometimes multiple user accounts may need to be offboarded at once. Doing this manually is a tedious task. Even using the script, it might still be difficult to do and re-do operations for multiple users.

To simplify your work, use the **–CSVFilePath** parameter and import the bulk user accounts to be offboarded. Everything can be accomplished in a single run of the script.

<img width="937" height="71" alt="image" src="https://github.com/user-attachments/assets/56e229c1-c5fb-4eb7-b792-0b4c819b08f5" />

**2. Use certificate-based authentication to offboard users**
You can use such Entra ID applications to leverage the enhanced security of OAuth2.0 authentication through our script.

To point to an application, use the –ClientID and –CertificateThumbprint parameters and provide the specific values.

<img width="953" height="70" alt="image" src="https://github.com/user-attachments/assets/6af4439f-b9da-47f3-a6ad-0c46a8a354be" />

**Note**: To perform any action using certificate-based authentication, the calling application must be assigned the **User.ReadWrite.All** app permission and at least the User Administrator Entra ID role.



