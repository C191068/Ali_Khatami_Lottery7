# Ali_Khatami_Lottery7(Learning from the video of Patrick Collins)

### Implementing Chainlink Keepers(performUpkeep)

In the code of this repo https://github.com/C191068/Ali_Khatami_Lottery6.git

we actually learn how to do trigger now we will write the function <br>
that will get executed after upkeepNeeded returns true <br>

This gonna be our performUpkeep function <br>


![k53](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/950c4697-eea1-4ac9-acd0-5ad4f07a8d84)


Now when it is time to pick a rando winner actually what we gonna do <br>
is just call this function <br>

So instead of having these extra function we will transform the above function shown in figure <br>

to performUpkeep function <br>


Since once checkUpkeep returns true the chainlink node will automatically call the <br>
performUpkeep function <br>

![k54](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/66433f60-3fa1-4622-9ea4-bf648dbbb2c5)

requsetRandomwinner replace to performUpkeep <br>


![k55](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/a2f2f599-700f-4d2c-a89d-a04d040926fb)


And we will have it to take input parameter as the above <br>


![k56](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/53eebf07-8782-4be8-a74d-d8ad8c98f7c8)

In our checkupkeep we ahve performData we will automatically pass it to performUpkeep <br>


We aree not gonna pass anything to performUpkeep we will leave it comment like the above <br>

![k57](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/02c006e3-55aa-4fb5-9ac8-04ebd3ea3462)


Since performUpkkep is identified in the AutomationCompatible interface it is now gonna <br>
be override <br>



































