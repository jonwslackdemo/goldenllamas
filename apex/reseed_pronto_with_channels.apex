// Delete the current 15 Pronto articles and re-seed with IsVisibleInCsp=true + IsVisibleInPkb=true at insert time.
// Previous attempts to flip the flags on draft+republish failed silently.

// Step 1: archive-delete the current ones
List<Knowledge__kav> existing = [SELECT Id, KnowledgeArticleId, UrlName, PublishStatus FROM Knowledge__kav WHERE UrlName LIKE 'pronto-%'];
Set<Id> articleIds = new Set<Id>();
for (Knowledge__kav k : existing) articleIds.add(k.KnowledgeArticleId);

Integer archived = 0;
for (Id aid : articleIds) {
  try {
    KbManagement.PublishingService.archiveOnlineArticle(aid, null);
    archived++;
  } catch (Exception e) {
    // might be already draft/archived
  }
}
// Hard delete the archived articles (new articles will have fresh UrlNames, so this is to be safe)
Integer hardDeleted = 0;
for (Id aid : articleIds) {
  try {
    KbManagement.PublishingService.deleteArchivedArticle(aid);
    hardDeleted++;
  } catch (Exception e) {
    // skip
  }
}
// Any remaining drafts: delete them via the PublishingService
List<Knowledge__kav> drafts = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE UrlName LIKE 'pronto-%' AND PublishStatus='Draft'];
for (Knowledge__kav d : drafts) {
  try { KbManagement.PublishingService.deleteDraftArticle(d.KnowledgeArticleId); } catch (Exception e) {}
}

// Step 2: reseed
Id faqRtId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('SDO_Knowledge_FAQ').getRecordTypeId();

List<Map<String, String>> faqs = new List<Map<String, String>>{
  new Map<String, String>{'title'=>'How do I check the status of my order?','url'=>'pronto-order-status','q'=>'How do I check my order status, and what do the statuses mean?','a'=>'You can check your order status at any time in the Pronto Help Centre. Sign in at pronto.com/orders, open the order, and the current status appears at the top. Statuses are: Received, Packed, Shipped, Out for Delivery, and Delivered. If your order was shipped we also show the carrier and tracking number on the same page.','c'=>'Sign in at pronto.com/orders to see your order status. Statuses are Received, Packed, Shipped, Out for Delivery, and Delivered.'},
  new Map<String, String>{'title'=>'How do I cancel an order?','url'=>'pronto-cancel-order','q'=>'How do I cancel a Pronto order, and when is cancellation possible?','a'=>'Pronto can cancel any order while its status is Received or Packed. Sign in to your Pronto account, open the order, and tap Cancel Order. Refunds are processed back to your original payment method within 3 business days. Orders already Shipped or Out for Delivery cannot be cancelled.','c'=>'You can cancel an order while its status is Received or Packed. Open the order and tap Cancel Order. Once Shipped it can\'t be cancelled.'},
  new Map<String, String>{'title'=>'How do I change my delivery address?','url'=>'pronto-change-delivery-address','q'=>'Can I change the delivery address on an order after I\'ve placed it?','a'=>'You can change your delivery address while an order is in Received or Packed status. Sign in to your Pronto account, open the order, tap Delivery details, and enter the new address. Address changes are not possible once the order has been shipped.','c'=>'Delivery addresses can be changed while the order is Received or Packed. Open the order and tap Delivery details.'},
  new Map<String, String>{'title'=>'What are Pronto\'s delivery options and times?','url'=>'pronto-delivery-options','q'=>'What delivery options and times does Pronto offer?','a'=>'Pronto offers three delivery options at checkout: Standard (3-5 business days, free on orders over $50), Express (next business day, $9.99), and Same-day (orders placed before 10 AM local time, available in 8 cities, $14.99).','c'=>'Standard: 3-5 business days (free over $50). Express: next business day ($9.99). Same-day: before 10 AM in 8 cities ($14.99).'},
  new Map<String, String>{'title'=>'How do I return an item?','url'=>'pronto-return-item','q'=>'How do I start a return for a Pronto order?','a'=>'Pronto accepts returns on most items within 30 days of delivery. To start a return, sign in to your account, open the order, tap Return items, and select the items and reason. We\'ll send a prepaid return label to your email. Refunds are processed in 3-5 business days after we receive the parcel.','c'=>'Open the order in your Pronto account, tap Return items, pick the items and reason. We email a prepaid label.'},
  new Map<String, String>{'title'=>'What is Pronto\'s return policy?','url'=>'pronto-return-policy','q'=>'What is Pronto\'s return window, and what items are not returnable?','a'=>'You have 30 days from the date of delivery to return most items for a full refund. Items must be unused and in original packaging. Final-sale items, gift cards, and personalized items are not eligible. Return shipping is free for Pronto One members; non-members pay a flat $4.99 return label fee.','c'=>'30-day return window. Final-sale, gift cards, and personalized items can\'t be returned. Return shipping is free for Pronto One; others pay $4.99.'},
  new Map<String, String>{'title'=>'What forms of payment does Pronto accept?','url'=>'pronto-payment-methods','q'=>'What payment methods does Pronto accept at checkout?','a'=>'Pronto accepts Visa, Mastercard, American Express, Discover, Apple Pay, Google Pay, PayPal, and Pronto Store Credit. We do not accept cash, personal cheques, money orders, or cryptocurrency. For orders over $500, Pronto also offers interest-free installments through Affirm at checkout.','c'=>'Pronto accepts Visa, Mastercard, Amex, Discover, Apple Pay, Google Pay, PayPal, and Pronto Store Credit. Affirm installments over $500.'},
  new Map<String, String>{'title'=>'How do I reset my Pronto password?','url'=>'pronto-reset-password','q'=>'How do I reset my Pronto account password?','a'=>'Go to pronto.com/signin and tap Forgot password. Enter the email address on your account and we\'ll email you a reset link within 2 minutes. The link is valid for 24 hours. Choose a new password of at least 10 characters including one number, and sign in.','c'=>'Go to pronto.com/signin, tap Forgot password, and we\'ll email you a reset link within 2 minutes. Link is valid for 24 hours.'},
  new Map<String, String>{'title'=>'How do I update my Pronto profile and contact details?','url'=>'pronto-update-profile','q'=>'How do I change my name, email, phone number, or address on my Pronto account?','a'=>'Sign in to pronto.com, open Account settings, and edit your name, email, phone number, or delivery addresses. Email changes require a one-time code sent to the new address. Phone number changes require a code sent by SMS.','c'=>'Open Account settings at pronto.com to edit your name, email, phone, or addresses. Email and phone changes need a one-time code.'},
  new Map<String, String>{'title'=>'What are Pronto\'s customer support opening hours?','url'=>'pronto-opening-hours','q'=>'When is Pronto customer support open?','a'=>'Pronto\'s chat and phone support are open Monday to Friday, 8 AM to 8 PM, and Saturday 9 AM to 5 PM, local time for your account\'s country. Closed on Sundays and public holidays. The Help Centre is available 24/7. Outside opening hours, the assistant can create a case for next-business-day response.','c'=>'Chat and phone: Mon-Fri 8 AM - 8 PM, Sat 9 AM - 5 PM local. Closed Sundays and public holidays. Help Centre is 24/7.'},
  new Map<String, String>{'title'=>'How do I contact a human Pronto agent?','url'=>'pronto-contact-human','q'=>'How do I escalate to a human agent?','a'=>'During opening hours (Monday-Friday 8 AM - 8 PM, Saturday 9 AM - 5 PM local time), ask the Pronto assistant to transfer you to a live agent and we\'ll route you to the next available teammate. Outside those hours, the assistant will log a case and a human agent will respond within one business day by email.','c'=>'During opening hours, ask the assistant to transfer you to a live agent. Outside hours, the assistant logs a case and a human responds within one business day.'},
  new Map<String, String>{'title'=>'What is Pronto One membership and how do I join?','url'=>'pronto-one-membership','q'=>'What is Pronto One, and what are the benefits?','a'=>'Pronto One is our paid loyalty programme. For $49 per year, members get free standard delivery on every order, free return shipping, early access to sales, and a dedicated priority chat queue. Join at pronto.com/one — it activates immediately and you\'ll see the Pronto One badge on your account.','c'=>'Pronto One costs $49/year. Benefits: free standard delivery, free returns, early sale access, priority chat queue. Join at pronto.com/one.'},
  new Map<String, String>{'title'=>'What is Pronto\'s warranty policy?','url'=>'pronto-warranty-policy','q'=>'What warranty does Pronto offer on its products?','a'=>'All Pronto-branded products include a 12-month manufacturer warranty from the date of delivery. The warranty covers defects in materials and workmanship but does not cover accidental damage, water damage, or normal wear. To make a warranty claim, open the order and tap Report an issue, then choose Warranty.','c'=>'Pronto-branded products carry a 12-month manufacturer warranty from delivery. Open the order and tap Report an issue → Warranty.'},
  new Map<String, String>{'title'=>'Is my personal information safe with Pronto?','url'=>'pronto-data-security','q'=>'How does Pronto protect my personal information?','a'=>'Pronto encrypts your personal information at rest and in transit using industry-standard AES-256 and TLS 1.3. We never share your email, phone, or address with third parties for marketing, and we never store your full payment card number. You can download or delete your data from Account settings > Privacy.','c'=>'Pronto encrypts data at rest (AES-256) and in transit (TLS 1.3), never sells your details, and never stores full card numbers.'},
  new Map<String, String>{'title'=>'How do I track my shipped Pronto order?','url'=>'pronto-track-shipped-order','q'=>'How do I track a Pronto order once it has shipped?','a'=>'Once your order ships, Pronto emails a tracking link to the email address on your account. You can also find the tracking link by signing in, opening the order, and tapping Track parcel. The tracking page shows the carrier (UPS, FedEx, USPS, or DHL), the latest scan location, and the estimated delivery date.','c'=>'We email a tracking link when your order ships. You can also find it on the order page under Track parcel.'}
};

List<Knowledge__kav> toInsert = new List<Knowledge__kav>();
for (Map<String, String> f : faqs) {
  Knowledge__kav draft = new Knowledge__kav(
    Title = f.get('title'),
    UrlName = f.get('url'),
    RecordTypeId = faqRtId,
    Language = 'en_US',
    Summary = f.get('c'),
    FAQ_Question__c = f.get('q'),
    FAQ_Answer__c = f.get('a'),
    Chat_Answer__c = f.get('c'),
    IsVisibleInCsp = true,
    IsVisibleInPkb = true,
    ValidationStatus = 'Validated'
  );
  toInsert.add(draft);
}
insert toInsert;

List<Knowledge__kav> inserted = [SELECT Id, KnowledgeArticleId, UrlName, IsVisibleInCsp, IsVisibleInPkb FROM Knowledge__kav WHERE Id IN :toInsert];

List<Knowledge__DataCategorySelection> cats = new List<Knowledge__DataCategorySelection>();
for (Knowledge__kav k : inserted) {
  cats.add(new Knowledge__DataCategorySelection(ParentId = k.Id, DataCategoryGroupName = 'Audience', DataCategoryName = 'Consumer'));
  cats.add(new Knowledge__DataCategorySelection(ParentId = k.Id, DataCategoryGroupName = 'Pronto', DataCategoryName = 'Help_Centre'));
}
insert cats;

List<String> log = new List<String>();
log.add('Archived: ' + archived + ' / HardDeleted: ' + hardDeleted + ' / Reseeded: ' + inserted.size());

Integer pubOk = 0;
for (Knowledge__kav k : inserted) {
  try {
    KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
    pubOk++;
  } catch (Exception e) {
    log.add('PubFail ' + k.UrlName + ': ' + e.getMessage());
  }
}
log.add('Published: ' + pubOk);

// Verify channel flags post-publish
List<Knowledge__kav> online = [SELECT UrlName, IsVisibleInCsp, IsVisibleInPkb FROM Knowledge__kav WHERE UrlName LIKE 'pronto-%' AND PublishStatus='Online'];
Integer withCsp = 0, withPkb = 0;
for (Knowledge__kav k : online) {
  if (k.IsVisibleInCsp) withCsp++;
  if (k.IsVisibleInPkb) withPkb++;
}
log.add('Post-publish check: online=' + online.size() + ' csp=' + withCsp + ' pkb=' + withPkb);

throw new System.AsyncException(String.join(log, '\n'));
