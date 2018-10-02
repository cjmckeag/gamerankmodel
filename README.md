# gamerankmodel
From my tenure with the Sacramento Kings: a predictive model that outputs the predicted revenue for each home game of the upcoming season.

Linear Model with Feature Selection: “gamerank.R”
•	Data gathering and cleaning
♣	Convert SeasonPart to factor
♣	SeasonPart is a categorical variable and not a quantitative variable 
♣	It is important to convert categorical variables to factors so that they can be implemented correctly in the model
•	Feature selection process
♣	Want to try to find the features which optimize the model and explain any correlation between features. We will use 2 different methods for choosing the best predictors to increase our chances of selecting the best model.
♣	Best Subsets Regression
♣	Selects the subset of predictors that do the best at meeting some well-defined objective criterion (Adjusted R2, which indicates how well terms fit a curve or line, but adjusts for the number of terms in a model)
♣	According to this method, the best subset of predictors is BigGame, LeBron, Rivalry, Weekend, Stars, Holiday, PastWins, and FootballSeason
♣	Interaction terms
•	Want to explain any correlation between features and their effect on each other. If two variables have a significant interaction, this means that one’s effect on the response is dependent on the value of the other.
•	Most significant interactions are between BigGame and Rivalry, and Rivalry and Stars
♣	Final best subsets model consists of the following terms: BigGame, LeBron, Rivalry, Weekend, Stars, Holiday, PastWins, FootballSeason, BigGame and Rivalry, and Rivalry and Stars
♣	Stepwise Regression
♣	Builds the regression model from a set of candidate predictor variables by entering and removing predictors — in a stepwise manner — into the model until there is no justifiable reason to enter or remove any more. Selects based on Aikake’s Information Criterion (AIC), which estimates the relative quality of the model.
♣	According to this method, the best features to include in the model are BigGame, LeBron, Rivalry, Weekend, Stars, Holiday, PastWins, FootballSeason, DaysSinceLast, and Facebook
•	Like the model chosen by best subsets regression, but this model includes the DaysSinceLast and Facebook variables
♣	Interaction terms
•	Most significant interactions are between BigGame and Rivalry, and Facebook and Facebook (Facebook2)
•	Adding these makes PastWins insignificant, so we remove it from the model
♣	Final stepwise regression model consists of the following terms: BigGame, LeBron, Rivalry, Weekend, Stars, Holiday, FootballSeason, DaysSinceLast, Facebook, BigGame and Rivalry, and Facebook2
•	Choosing the model
♣	PRESS: Predicted Residual Sum of Squares
♣	PRESS is a form of cross-validation which provides a summary measure of the fit of a model to a sample of observations that were not themselves used to estimate the model. It is calculated as the sums of squares of the prediction residuals for those observations.
♣	PRESS is a better criterion to base our choice upon because it measures the model’s predictive power, rather than its accuracy of fitting our known data points.
♣	The stepwise regression model has a lower (better) PRESS value than the subset model, so we will use the stepwise model.
•	Residual Analysis
♣	Residual analysis is a vital part of regression. Residuals are defined as the difference between the predictions of a model and the actual values. A linear regression model is not always appropriate for the data, so we should assess the appropriateness of the model by examining various residual plots and performing tests.
♣	Homoskedasticity
♣	Homoskedasticity is the characteristic that the residuals of a model have equal, constant variances.
♣	After performing a test on the residuals for non-constant variance, we see that the residuals have significantly unequal variances, and thus the plot is heteroskedastic.
♣	When the residual variance increases with the fitted values, then prediction intervals will tend to be wider than they should be at low fitted values and narrower than they should be at high fitted values.
♣	To fix this, we weight the variances so that they can be different for each set of predictor values. The data observations are given different weights when estimating the model. Since some points spread out more, they provide less information about the location of the mean than other points. By providing a weight with each data point, the model can incorporate this.
♣	After adding the weights and retesting the model, there is no significant non-constant variance found.
♣	Linearity
♣	The relationship between the independent and dependent variables must be linear for a linear model to be a valid fit.
♣	Based on the plot, the data is linear. There is no sign of nonlinearity in the plot.
♣	Normality
♣	Violations of normality create problems for determining whether model coefficients are significantly different from zero.
♣	To check normality, we create a histogram of the studentized residuals and check if the plot resembles a normal distribution.
♣	We can see that the curve is approximately normal and proceed with the normality assumption.
♣	Independence
♣	We must check if there is any autocorrelation between the residuals. Usually this is more applicable in a time series model, where it is possible that the errors decrease or increase as time goes on.
♣	Serial correlation in the errors (i.e., correlation between consecutive errors or errors separated by some other number of periods) means that there is room for improvement in the model, and extreme serial correlation is often a symptom of a badly mis-specified model.
♣	We can use the Durbin-Watson test for autocorrelation. The residuals pass the test, thus are independent.
♣	After some transformation, the model passes all linear regression assumptions and we can proceed with the weighted model.
•	Cross Validation
♣	Cross-validation is a technique to evaluate predictive models by partitioning the original sample into a training set to train the model, and a test set to evaluate it.
♣	The “lm” (linear model) method of cross validation suits the data the best, as when it is trained with this model it yields the lowest RMSE, or Root Mean Square Error (the square root of the average squared error between predicted and actual values in the dataset)
♣	Multiple other regression models were attempted for training this model, such as gradient boosting, random forest, k nearest neighbors, and bagging. These methods all involve complex decision tree/machine learning algorithms.  After tuning parameters for these models, none of them had as low of an RMSE as the linear model (see RMSE comparison in appendix).
•	Final model
♣	After feature selection, residual analysis, and cross validation, a simple linear regression model is the best type of model for this dataset. 

Model without feature selection or residual analysis: “gamerank_fulldata.R”
•	Intro
o	To find the best model, I built a model that incorporates all the features in the data and does not use any variable selection methods to choose the “best” predictors. I also did not perform any residual analysis on this model.
•	Data gathering, cleaning, and transformation
o	3 options considered for data: remove near zero variance variables, remove highly correlated variables, and or transform the data using centering, scaling, and Yeo-Johnson.
♣	Near Zero Variance Variables (LeBron) can cause problems when it comes to splitting the data for training. They may cause the model to crash and may contain very little information and predictive power.
♣	Highly Correlated Variables (OverUnders) increase the variance of the regression coefficients, making them unstable, and add redundant information to the model.
♣	Centering, scaling, and the Yeo-Johnson transformation help stabilize variance, normalize the data, improve validity of measures of association between variable, and improve multivariate normality.
♣	To find out which model using what data alterations has the most predictive strength, I ran the following: (see: “testingdatachanges.R”)
•	A program that trains a model on transformed data, and then trains a model on the original data, hundreds of times. I averaged the RMSE values for each model from every iteration. The model trained on the original non-transformed data has a slightly lower RMSE, so moving forward I did NOT transform the data.
•	A program that trains 4 models: one without LeBron or OverUnders, one with LeBron but without OverUnders, one with OverUnders but without LeBron, and one with both LeBron and OverUnders. The model without either of the variables had the highest RMSE, and the one with LeBron and without OverUnders had the lowest RMSE, so moving forward I removed ONLY OverUnders.
•	In summary: do not transform the data and do remove OverUnders.
o	Cross Validation and Finding the Right Model
♣	I trained multiple models using the following methods: gradient boosting, random forest, bagging, extreme gradient boosting, k nearest neighbors, and linear regression. After tuning specific parameters to optimize each model, the model with the lowest RMSE is the linear regression model (see RMSE comparison in appendix). Again, showing that a linear model suits this data the best.
•	Final Model
o	The final model using no variable selection methods is the linear model trained on non-transformed data with the highly correlated variable OverUnders removed.

Which model to use: with or without feature selection?
The model that uses feature selection has a lower RMSE than the model that does not use feature selection nor residual analysis. Thus, my final model is the linear regression model which uses feature selection and residual analysis. This is likely because using feature selection allows for elimination of variables that do not add any predictive strength to the model, and residual analysis allows for any violations of assumptions of a linear model to be corrected. This model uses the following features:

BigGame, LeBron, Rivalry, Weekend, Stars, Holiday, FootballSeason, DaysSinceLast, Facebook, BigGame and Rivalry, and Facebook2
