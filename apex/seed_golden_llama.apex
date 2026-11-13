// Seed the 2024 Golden Llama Awards: 1 Edition, 2 Categories (Best Actress + Best Actor), 10 Nominees.
// Idempotent: deletes any pre-existing Golden Llama data first.

// Clean slate — only delete Golden Llama records (safe, demo-scoped)
delete [SELECT Id FROM Nominee__c];
delete [SELECT Id FROM Category__c];
delete [SELECT Id FROM Award_Edition__c];

Award_Edition__c edition = new Award_Edition__c(
  Name = '2024 Golden Llama Awards',
  Year__c = 2024,
  Ceremony_Date__c = Date.newInstance(2024, 3, 10)
);
insert edition;

Category__c bestActress = new Category__c(
  Name = 'Best Actress — 2024 Golden Llamas',
  Award_Edition__c = edition.Id,
  Short_Name__c = 'Best Actress',
  Description__c = 'Lead female performance in a feature film.'
);
Category__c bestActor = new Category__c(
  Name = 'Best Actor — 2024 Golden Llamas',
  Award_Edition__c = edition.Id,
  Short_Name__c = 'Best Actor',
  Description__c = 'Lead male performance in a feature film.'
);
insert new List<Category__c>{ bestActress, bestActor };

List<Nominee__c> nominees = new List<Nominee__c>{
  // Best Actress — 5 nominees, Emma Stone wins
  new Nominee__c(
    Nominee_Name__c = 'Emma Stone', Role__c = 'Bella Baxter', Film__c = 'Poor Things',
    Category__c = bestActress.Id, Won__c = true,
    Winner_Statement__c = 'Emma Stone took the Golden Llama for Best Actress for her performance as Bella Baxter in Poor Things. Her second Golden Llama in the lead actress category.',
    Nominee_Email__c = 'emma.stone@example.com', Phone__c = '+44 20 0000 0001'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Annette Bening', Role__c = 'Diana Nyad', Film__c = 'Nyad',
    Category__c = bestActress.Id, Won__c = false,
    Nominee_Email__c = 'annette.bening@example.com', Phone__c = '+44 20 0000 0002'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Lily Gladstone', Role__c = 'Mollie Burkhart', Film__c = 'Killers of the Flower Moon',
    Category__c = bestActress.Id, Won__c = false,
    Nominee_Email__c = 'lily.gladstone@example.com', Phone__c = '+44 20 0000 0003'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Sandra Hüller', Role__c = 'Sandra Voyter', Film__c = 'Anatomy of a Fall',
    Category__c = bestActress.Id, Won__c = false,
    Nominee_Email__c = 'sandra.huller@example.com', Phone__c = '+44 20 0000 0004'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Carey Mulligan', Role__c = 'Felicia Montealegre', Film__c = 'Maestro',
    Category__c = bestActress.Id, Won__c = false,
    Nominee_Email__c = 'carey.mulligan@example.com', Phone__c = '+44 20 0000 0005'
  ),
  // Best Actor — 5 nominees, Cillian Murphy wins
  new Nominee__c(
    Nominee_Name__c = 'Cillian Murphy', Role__c = 'J. Robert Oppenheimer', Film__c = 'Oppenheimer',
    Category__c = bestActor.Id, Won__c = true,
    Winner_Statement__c = 'Cillian Murphy took the Golden Llama for Best Actor for his performance as J. Robert Oppenheimer. His first Golden Llama.',
    Nominee_Email__c = 'cillian.murphy@example.com', Phone__c = '+44 20 0000 0006'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Bradley Cooper', Role__c = 'Leonard Bernstein', Film__c = 'Maestro',
    Category__c = bestActor.Id, Won__c = false,
    Nominee_Email__c = 'bradley.cooper@example.com', Phone__c = '+44 20 0000 0007'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Colman Domingo', Role__c = 'Bayard Rustin', Film__c = 'Rustin',
    Category__c = bestActor.Id, Won__c = false,
    Nominee_Email__c = 'colman.domingo@example.com', Phone__c = '+44 20 0000 0008'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Paul Giamatti', Role__c = 'Paul Hunham', Film__c = 'The Holdovers',
    Category__c = bestActor.Id, Won__c = false,
    Nominee_Email__c = 'paul.giamatti@example.com', Phone__c = '+44 20 0000 0009'
  ),
  new Nominee__c(
    Nominee_Name__c = 'Jeffrey Wright', Role__c = 'Thelonious "Monk" Ellison', Film__c = 'American Fiction',
    Category__c = bestActor.Id, Won__c = false,
    Nominee_Email__c = 'jeffrey.wright@example.com', Phone__c = '+44 20 0000 0010'
  )
};
insert nominees;

throw new System.AsyncException('Seeded: 1 Edition + 2 Categories + ' + nominees.size() + ' Nominees. Carey Mulligan Id: ' + nominees[4].Id);
