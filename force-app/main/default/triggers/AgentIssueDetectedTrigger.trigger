/**
 * Fires on every Agent_Issue_Detected__e Platform Event and enqueues a
 * Queueable that POSTs the payload to the Slack Golden Llama webhook.
 *
 * Platform Event triggers can't do callouts in the same transaction, so
 * we enqueue a Queueable (which permits callouts) to run the HTTP POST.
 */
trigger AgentIssueDetectedTrigger on Agent_Issue_Detected__e (after insert) {
    System.enqueueJob(new SlackWebhookPoster(Trigger.new));
}
