using eFood.Subscriber;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

Console.WriteLine("Hello, World!");

/*var bus = RabbitHutch.CreateBus("host=localhost:5672");
await bus.PubSub.SubscribeAsync<DoktoriActivated>( "seminarski", msg => {
    Console.WriteLine($"Doktor activated: {msg.Doktor.Ime}");
});
Console.WriteLine("Listening for messages, press <return> key to close!");
Console.ReadLine();*/

var factory = new ConnectionFactory
{
    HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "rabbitmq",
    Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
    UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "test",
    Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "test"
};

factory.ClientProvidedName = "Rabbit Test Consumer";
IConnection connection = factory.CreateConnection();
IModel channel = connection.CreateModel();

string exchangeName = "EmailExchange";
string routingKey = "email_queue";
string queueName = "EmailQueue";

channel.ExchangeDeclare(exchangeName, ExchangeType.Direct);
channel.QueueDeclare(queueName, true, false, false, null);
channel.QueueBind(queueName, exchangeName, routingKey, null);

var consumer = new EventingBasicConsumer(channel);

consumer.Received += (sender, args) =>
{
    var body = args.Body.ToArray();
    string message = Encoding.UTF8.GetString(body);

    Console.WriteLine($"Message received: {message}");
    EmailService emailService = new EmailService();
    emailService.SendEmail(message);

    channel.BasicAck(args.DeliveryTag, false);
};

channel.BasicConsume(queueName, false, consumer);

Console.WriteLine("Waiting for messages. Press Q to quit.");

Thread.Sleep(Timeout.Infinite);

channel.Close();
connection.Close();