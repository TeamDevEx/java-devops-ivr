package com.java.ivr.demo_ivr;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;

@ExtendWith(MockitoExtension.class)
class IvrPubSubscriberTest {

    @Mock
    private IVRService ivrService;

    @Mock
    private Storage storage;

    private IvrPubSubscriber ivrPubSubscriber;

    @BeforeEach
    void setUp() {
        ivrPubSubscriber = new IvrPubSubscriber(ivrService) {
            @Override
            protected Storage initializeStorage() {
                return storage;
            }
        };
    }

    @Test
    void testWriteToCloudStorage() {
        // Arrange
        String userInput = "test input";
        String response = "test response";
        when(storage.create(any(BlobInfo.class), any(byte[].class))).thenReturn(null);

        // Act
        ivrPubSubscriber.writeToCloudStorage(userInput, response);

        // Assert
        ArgumentCaptor<BlobInfo> blobInfoCaptor = ArgumentCaptor.forClass(BlobInfo.class);
        ArgumentCaptor<byte[]> contentCaptor = ArgumentCaptor.forClass(byte[].class);

        verify(storage).create(blobInfoCaptor.capture(), contentCaptor.capture());

        BlobInfo capturedBlobInfo = blobInfoCaptor.getValue();
        String capturedContent = new String(contentCaptor.getValue());

        assertEquals("java-devops-ivr", capturedBlobInfo.getBucket());
        assertTrue(capturedBlobInfo.getName().startsWith("ivr-response-"));
        assertEquals("application/json", capturedBlobInfo.getContentType());
        assertTrue(capturedContent.contains(userInput));
        assertTrue(capturedContent.contains(response));
    }

}
