using Devcon.SampleSite.Models;
using System;
using Xunit;

namespace Devcon.SampleSite.UnitTests
{
    public class DummyViewModelTests
    {
        [Fact]
        public void SampleSite_DummyTest1()
        {
            // Arrange 
            var model = new DummyViewModel();
            var firstNumber = 10;
            var secondNumber = 20;
            // Act
            var result = model.Add(firstNumber, secondNumber);

            // Assert
            Assert.Equal(30, result);
        }
    }
}
