Architecture for this project:


<img width="484" alt="image" src="https://github.com/user-attachments/assets/b7dfc830-f226-4cc6-913c-d4ea28f797b8" />



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

     ![image](https://github.com/user-attachments/assets/99987545-eac5-47d4-9d16-69fdda2db0c2)}

10.	Open a New Query Tool to Run the init.sql script – After the execution we can verify the objects were created successfully


    ![image](https://github.com/user-attachments/assets/a72c605b-8e2f-47d0-96c7-90059bb09ab9)

11. TBRAND table before inserting or adding campaigns:

    ![image](https://github.com/user-attachments/assets/90012ee9-5bbc-4e17-af08-9b3ec892a7cd)

    TBrand table after inserting campaigns with initial cost: We see the updated spent_today and spent_monthly by the trigger:


    ![image](https://github.com/user-attachments/assets/8cd7e12e-24fa-4868-bbe3-ef6d35812537)

    Tcampaign Table after insert:

    ![image](https://github.com/user-attachments/assets/aea5307b-1e29-4f17-8808-9b11d2600f1d)

    After adding new expenses for brand with id 3 that surpasses the daily cost, debt is added to the brand

    ![image](https://github.com/user-attachments/assets/051b2739-f3c8-4b87-bd97-223773ef368e)

    Tspend Table:


    ![image](https://github.com/user-attachments/assets/6ec9945a-13d2-4ca1-9b22-c3b220368d86)

    All campaigns are marked as inactive because of the trigger behavior for tcampaign table:


    ![image](https://github.com/user-attachments/assets/546722a4-f033-45ad-b43c-d91aacabcb39)



Now we are going to create the microservice related to the Python Middleware:

1.	Running the following docker command  inside the project route in order to build the customized image:

docker build -t flask-postgres-app .

2.	Running the following command to start the container attached to the DB network:

docker run -p 5000:5000 --network clientnet -e DB_USER=postgres -e DB_PASSWORD=pass123 -e POSTGRES_PASSWORD=pass123 -e DB_HOST=postgresCont -e DB_NAME=postgres -d flask-postgres-app

3.	Now we are able to send requests to our Middleware. The following example show a get requests for the Monthly Budget for each Brand: curl http://localhost:5000/brands/budget


![image](https://github.com/user-attachments/assets/34080504-3bb4-4e06-9425-30b28a112df6)

![image](https://github.com/user-attachments/assets/a28b5848-407f-4504-b059-de90ae702a28)

Now, we have the monthly or daily reset methods


![image](https://github.com/user-attachments/assets/61bb7709-24b2-4c84-afc4-052ddc5d3cba)


![image](https://github.com/user-attachments/assets/dafb4c7c-532a-4a99-afde-0695d2786334)

Before: 

![image](https://github.com/user-attachments/assets/ae9ba0a4-ab9c-40bd-861f-fdf1cec84446)

After:


![image](https://github.com/user-attachments/assets/eb8ddcd8-f03d-4f55-ab96-71fc961067f2)


Managing dayparting – note that this method could be set up to be executed several times in a day:


![image](https://github.com/user-attachments/assets/3ac11868-c178-40b1-a283-4a26364da18e)


Before - tcampaign:

![image](https://github.com/user-attachments/assets/615d6317-5f4a-4f80-a78b-10888224b9a5)

After – tcampaign


![image](https://github.com/user-attachments/assets/95241705-9f45-4f95-b40a-828ea8737fb9)

Now, I implemented a restful service for activating campaigns with no debt. As well as the previous method, this could be set up to run at certain hours or days according to the requirements needed.

As you can see all campaigns associated with Nike and Adidas (1,2) should be active: 

Before - tbrand


![image](https://github.com/user-attachments/assets/5ede0e5f-45bc-49a6-8ffd-b07ee58eb265)

![image](https://github.com/user-attachments/assets/927549aa-d54c-4b68-98e3-0c619fee6c20)

After:


![image](https://github.com/user-attachments/assets/d2b95e4b-228a-4c81-a5c3-f77c103c05f2)

![image](https://github.com/user-attachments/assets/0ef78bd3-ffcf-4ad6-9b07-01fd87334a80)

Now, we also have the function for registering new expenses as a service in the Middleware:

Before tspend:


![image](https://github.com/user-attachments/assets/ccc112d2-41f2-4968-847b-1b2f12d04826)


![image](https://github.com/user-attachments/assets/697dba97-97ef-4a0e-85fe-4788c6f4eb23)

After Request:


![image](https://github.com/user-attachments/assets/cda21438-680c-4439-9460-117e3e50bea6)

![image](https://github.com/user-attachments/assets/4597a1e3-306e-4ba5-a093-f8f007417408)


![image](https://github.com/user-attachments/assets/4ed5affe-1014-451e-9bf3-fb7a219109e4)

If we execute the same again for 600$, debt is added:


![image](https://github.com/user-attachments/assets/07bd18cb-79e8-4efe-b845-24652ad71f8d)


![image](https://github.com/user-attachments/assets/8b9aeb9b-3a61-4759-b4d3-e926c118b1ad)

Campaigns associated with brand 1 are also marked as inactive because of debt:


![image](https://github.com/user-attachments/assets/8dc8068f-fdf7-43a0-bfa2-ac281ec05e4c)

























 


