package com.java.ivr.demo_ivr;

import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.time.Instant;

import com.google.cloud.pubsub.v1.MessageReceiver;
import com.google.cloud.pubsub.v1.Subscriber;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import com.google.pubsub.v1.ProjectSubscriptionName;

import jakarta.annotation.PostConstruct;

@Component
public class IvrPubSubscriber {

    private final IVRService ivrService;
    private Storage storage;

    public IvrPubSubscriber(IVRService ivrService) {
        this.ivrService = ivrService;
        this.storage = initializeStorage();
    }

    protected Storage initializeStorage() {
        return StorageOptions.getDefaultInstance().getService();
    }

    protected Storage getStorage() {
        return this.storage;
    }

    @PostConstruct
    public void subscribe() {
        String subscriptionId = "java-devops-ivr-sub";
        ProjectSubscriptionName subscriptionName = ProjectSubscriptionName.of("off-net-dev", subscriptionId);

        Subscriber subscriber = Subscriber.newBuilder(subscriptionName, (MessageReceiver) (message, consumer) -> {
            String userInput = message.getData().toStringUtf8();
            System.out.println("Received: " + userInput);

            // Process input
            String response = ivrService.processUserInput(userInput);

            // Write to Cloud Storage
            writeToCloudStorage(userInput, response);

            consumer.ack();
        }).build();

        subscriber.startAsync().awaitRunning();
    }

    protected void writeToCloudStorage(String userInput, String response) {
        String bucketName = "java-devops-ivr";
        String objectName = "ivr-response-" + Instant.now().toEpochMilli() + ".json";

        String json = String.format("""
                {
                  "timestamp": "%s",
                  "userInput": "%s",
                  "response": "%s"
                }
                """, Instant.now().toString(), userInput, response);

        BlobId blobId = BlobId.of(bucketName, objectName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setContentType("application/json").build();

        storage.create(blobInfo, json.getBytes(StandardCharsets.UTF_8));
        System.out.println("Response saved to Cloud Storage: " + objectName);
    }

}
