// Seed the 2024 Golden Llama Awards: 1 Edition, 2 Categories, 10 Nominees.
// Only uses fields that deployed successfully. The deploy anomaly left out
// non-required fields (Role, Won, Winner_Statement, Nominee_Email, Phone,
// Ceremony_Date, Description) — those are not needed for the demo since
// GetNomineeRecordCorrect hardcodes winner statements by category.
// Idempotent: deletes any pre-existing records first.

delete [SELECT Id FROM Nominee__c];
delete [SELECT Id FROM Category__c];
delete [SELECT Id FROM Award_Edition__c];

Award_Edition__c edition = new Award_Edition__c(
    Name = '2024 Golden Llama Awards',
    Year__c = 2024
);
insert edition;

Category__c bestActress = new Category__c(
    Name = 'Best Actress — 2024 Golden Llamas',
    Short_Name__c = 'Best Actress',
    Award_Edition__c = edition.Id
);
Category__c bestActor = new Category__c(
    Name = 'Best Actor — 2024 Golden Llamas',
    Short_Name__c = 'Best Actor',
    Award_Edition__c = edition.Id
);
insert new List<Category__c>{ bestActress, bestActor };

List<Nominee__c> noms = new List<Nominee__c>{
    new Nominee__c(Nominee_Name__c='Emma Stone',        Film__c='Poor Things',                 Category__c=bestActress.Id),
    new Nominee__c(Nominee_Name__c='Annette Bening',    Film__c='Nyad',                        Category__c=bestActress.Id),
    new Nominee__c(Nominee_Name__c='Lily Gladstone',    Film__c='Killers of the Flower Moon', Category__c=bestActress.Id),
    new Nominee__c(Nominee_Name__c='Sandra Hüller',     Film__c='Anatomy of a Fall',          Category__c=bestActress.Id),
    new Nominee__c(Nominee_Name__c='Carey Mulligan',    Film__c='Maestro',                    Category__c=bestActress.Id),
    new Nominee__c(Nominee_Name__c='Cillian Murphy',    Film__c='Oppenheimer',                Category__c=bestActor.Id),
    new Nominee__c(Nominee_Name__c='Bradley Cooper',    Film__c='Maestro',                    Category__c=bestActor.Id),
    new Nominee__c(Nominee_Name__c='Colman Domingo',    Film__c='Rustin',                     Category__c=bestActor.Id),
    new Nominee__c(Nominee_Name__c='Paul Giamatti',     Film__c='The Holdovers',              Category__c=bestActor.Id),
    new Nominee__c(Nominee_Name__c='Jeffrey Wright',    Film__c='American Fiction',           Category__c=bestActor.Id)
};
insert noms;

// Smoke test both Apex classes
GetNomineeRecordCorrect.Request req1 = new GetNomineeRecordCorrect.Request();
req1.nomineeName = 'Carey Mulligan';
List<GetNomineeRecordCorrect.Response> r1 = GetNomineeRecordCorrect.lookup(new List<GetNomineeRecordCorrect.Request>{ req1 });

GetNomineeRecordWrong.Request req2 = new GetNomineeRecordWrong.Request();
req2.nomineeName = 'Carey Mulligan';
List<GetNomineeRecordWrong.Response> r2 = GetNomineeRecordWrong.lookup(new List<GetNomineeRecordWrong.Request>{ req2 });

throw new System.AsyncException(
    'Seeded: 1 Edition + 2 Categories + ' + noms.size() + ' Nominees.\n' +
    'CORRECT lookup for Carey Mulligan:\n' +
    '  matched=' + r1[0].nomineeMatched + ' category=' + r1[0].categoryShortName + ' film=' + r1[0].film + '\n' +
    '  winner=' + r1[0].winnerStatement + '\n' +
    'WRONG lookup for Carey Mulligan:\n' +
    '  matched=' + r2[0].nomineeMatched + ' category=' + r2[0].categoryShortName + ' film=' + r2[0].film + '\n' +
    '  winner=' + r2[0].winnerStatement
);
