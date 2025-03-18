Steps to Run the project and tests:

1.	Having docker installed
2.	Cloning the gir project
3.	From a VS Code terminal: 
Create a Network to communicate the Database with the PGAdmin Client and the Python Middleware:

Docker network create clientnet

![image](https://github.com/user-attachments/assets/b7b020ae-8843-410b-bf2d-e5662a698ddf)

4.	Create a Container (Microservice) for the PostgreSQL Database:

docker run -d --name postgresCont -p 5432:5432 -e POSTGRES_PASSWORD=pass123 --net clientnet postgres

![image](https://github.com/user-attachments/assets/5b90572e-1844-4817-998a-907b0cc48174)


5.	Create a Container (Microservice) for the PgAdmin Client to interact with the Database:

![image](https://github.com/user-attachments/assets/edeec90f-ad73-4566-9b41-62f410fe4deb)

6.	Open localhost at port 82 and enter the credentials passed as environment variables to the containers

   ![image](https://github.com/user-attachments/assets/0b51b811-8d78-498c-9536-a37f534015ee)

 7.	After login in:

   	![image](https://github.com/user-attachments/assets/209bdfe5-b090-4184-82ac-ed11c11e2ab5)

 8.	Create a New Sever making sure the host name matches the DB container name


    ![image](https://github.com/user-attachments/assets/cf99c1b8-ff8f-431e-bf68-8c1f096942a9)
   	
   	![image](https://github.com/user-attachments/assets/3f0476c8-33a0-4369-9d25-31c0eb943b64)

  9. After creating the server:


      ![image](https://github.com/user-attachments/assets/6975675f-6419-488d-a721-05a4f0ba955e)

     ![image](https://github.com/user-attachments/assets/99987545-eac5-47d4-9d16-69fdda2db0c2)









 


