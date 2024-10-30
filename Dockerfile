FROM openjdk:8-jdk-alpine
WORKDIR /app
EXPOSE 8082
COPY petclinic.war /app/petclinic.war
CMD ["java","-jar","/app/petclinic.war", "--server.port=8082"]
