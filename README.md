Steps to Run the project and tests:

1.	Having docker installed
2.	Cloning the gir project
3.	From a VS Code terminal: 
Create a Network to communicate the Database with the PGAdmin Client and the Python Middleware:

Docker network create clientnet

![image](https://github.com/user-attachments/assets/b7b020ae-8843-410b-bf2d-e5662a698ddf)

4.	Create a Container (Microservice) for the PostgreSQL Database:

docker run -d --name postgresCont -p 5432:5432 -e POSTGRES_PASSWORD=pass123 --net clientnet postgres


5.	Create a Container (Microservice) for the PgAdmin Client to interact with the Database:

 

6.	Open localhost at port 82 and enter the credentials passed as environment variables to the containers
 


