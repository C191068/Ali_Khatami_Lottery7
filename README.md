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

We gonna do a lit bit valaidation because right now anybody can call our performUpkeep function <br>

We have to make sure it only gets called when checkupkeep is true <br>


An easy way to do that is to call our own checkupkeep function <br>

As checkupkeep is external we can't call our own checkup function <br>

![k58](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/04410442-7aa6-4642-a5d3-2928f4dfaeed)

So we made it public so that our own smart contarct can call these chcekupkeep function  <br>



![k59](https://github.com/C191068/Ali_Khatami_Lottery7/assets/89090776/7a7c90ff-20fc-457f-aad9-230f9705a1d9)

In performUpkeep we can call checkUpkeep passing nothing and return upkeepneeded and performdata,<br> 
performdata is not needed and for that we giv ethe above line of code  <br>
























































